class CalendarConnectionsController < ApplicationController
  before_action :set_calendar_connection, only: [ :show, :events ]

  def new
    @calendar_connection = Current.user.calendar_connection
  end

  def create
    client_id = Rails.application.credentials.dig(:google, :client_id)
    redirect_uri = Rails.application.credentials.dig(:google, :redirect_uri) || callback_calendar_connection_url
    scope = Rails.application.config.google_calendar_scope

    auth_url = "https://accounts.google.com/o/oauth2/v2/auth?" + {
      client_id: client_id,
      redirect_uri: redirect_uri,
      response_type: "code",
      scope: scope,
      access_type: "offline",
      prompt: "consent"
    }.to_query

    redirect_to auth_url, allow_other_host: true
  end

  def callback
    if params[:error].present?
      redirect_to new_calendar_connection_path, alert: "Authorization failed: #{params[:error]}"
      return
    end

    code = params[:code]
    unless code.present?
      redirect_to new_calendar_connection_path, alert: "Authorization code missing"
      return
    end

    client_id = Rails.application.credentials.dig(:google, :client_id)
    client_secret = Rails.application.credentials.dig(:google, :client_secret)
    redirect_uri = Rails.application.credentials.dig(:google, :redirect_uri) || callback_calendar_connection_url

    token_client = Signet::OAuth2::Client.new(
      token_credential_uri: "https://oauth2.googleapis.com/token",
      client_id: client_id,
      client_secret: client_secret,
      redirect_uri: redirect_uri,
      code: code
    )

    begin
      token_client.fetch_access_token!

      calendar_service = Google::Apis::CalendarV3::CalendarService.new
      calendar_service.authorization = token_client
      calendar_list = calendar_service.list_calendar_lists
      primary_calendar = calendar_list.items.find { |cal| cal.primary } || calendar_list.items.first
      google_email = primary_calendar&.id || Current.user.email_address

      connection = Current.user.calendar_connection || Current.user.build_calendar_connection
      expires_in = token_client.expires_in || 3600
      connection.update!(
        provider: "google",
        access_token: token_client.access_token,
        refresh_token: token_client.refresh_token,
        expires_at: Time.current + expires_in.seconds,
        google_email: google_email
      )

      redirect_to events_calendar_connection_path, notice: "Calendar connected successfully"
    rescue StandardError => e
      Rails.logger.error "Calendar connection error: #{e.message}"
      redirect_to new_calendar_connection_path, alert: "Failed to connect calendar: #{e.message}"
    end
  end

  def show
  end

  def events
    unless @calendar_connection
      redirect_to new_calendar_connection_path, alert: "Please connect your calendar first"
      return
    end

    @service = GoogleCalendarService.new(@calendar_connection)
    @events = @service.fetch_recurring_events
  rescue StandardError => e
    Rails.logger.error "Error fetching events: #{e.message}"
    @events = []
    flash.now[:alert] = "Failed to fetch events: #{e.message}"
  end

  def select_event
    unless Current.user.calendar_connection
      redirect_to new_calendar_connection_path, alert: "Please connect your calendar first"
      return
    end

    event_id = params[:event_id]
    calendar_id = params[:calendar_id] || "primary"

    unless event_id.present?
      redirect_to events_calendar_connection_path, alert: "Event ID is required"
      return
    end

    service = GoogleCalendarService.new(Current.user.calendar_connection)
    event = service.get_event_details(event_id, calendar_id)

    default_team = Current.user.team_memberships.first&.team
    unless default_team
      redirect_to events_calendar_connection_path, alert: "You must belong to a team first"
      return
    end

    calendar_event = CalendarEvent.create!(
      user: Current.user,
      team: default_team,
      provider: "google",
      event_id: event.id,
      calendar_id: calendar_id,
      refresh_token: Current.user.calendar_connection.refresh_token
    )

    redirect_to events_calendar_connection_path, notice: "Event '#{event.summary}' has been saved"
  rescue StandardError => e
    Rails.logger.error "Error selecting event: #{e.message}"
    redirect_to events_calendar_connection_path, alert: "Failed to save event: #{e.message}"
  end

  def destroy
    if @calendar_connection = Current.user.calendar_connection
      @calendar_connection.destroy
      redirect_to new_calendar_connection_path, notice: "Calendar disconnected successfully"
    else
      redirect_to new_calendar_connection_path, alert: "No calendar connection found"
    end
  end

  private

  def set_calendar_connection
    @calendar_connection = Current.user.calendar_connection
  end
end
