class GoogleCalendarService
  def initialize(calendar_connection)
    @calendar_connection = calendar_connection
    @service = Google::Apis::CalendarV3::CalendarService.new
    @service.authorization = credentials
  end

  def fetch_recurring_events
    ensure_valid_token

    events = []
    page_token = nil

    loop do
      result = @service.list_events(
        "primary",
        max_results: 2500,
        page_token: page_token,
        single_events: false,
        order_by: "startTime"
      )

      recurring_events = result.items.select { |event| event.recurrence.present? }
      events.concat(recurring_events)

      page_token = result.next_page_token
      break if page_token.nil?
    end

    events
  end

  def get_event_details(event_id, calendar_id = "primary")
    ensure_valid_token
    @service.get_event(calendar_id, event_id)
  end

  private

  def credentials
    Google::Auth::UserRefreshCredentials.new(
      client_id: Rails.application.credentials.dig(:google, :client_id),
      client_secret: Rails.application.credentials.dig(:google, :client_secret),
      refresh_token: @calendar_connection.refresh_token,
      access_token: @calendar_connection.access_token
    )
  end

  def ensure_valid_token
    if @calendar_connection.expired?
      @calendar_connection.refresh_access_token!
      @service.authorization = credentials
    end
  end
end
