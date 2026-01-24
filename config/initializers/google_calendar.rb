Rails.application.config.google_calendar_client_id = Rails.application.credentials.dig(:google, :client_id)
Rails.application.config.google_calendar_client_secret = Rails.application.credentials.dig(:google, :client_secret)
Rails.application.config.google_calendar_redirect_uri = Rails.application.credentials.dig(:google, :redirect_uri) || "#{Rails.application.config.action_mailer.default_url_options[:host]}/calendar_connection/callback"
Rails.application.config.google_calendar_scope = "https://www.googleapis.com/auth/calendar.readonly"
