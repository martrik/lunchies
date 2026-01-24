# Use same Google OAuth client as calendar; add /google_sign_in/callback as redirect URI in Google Cloud Console
Rails.application.configure do
  config.google_sign_in.client_id     = Rails.application.credentials.dig(:google, :client_id)
  config.google_sign_in.client_secret = Rails.application.credentials.dig(:google, :client_secret)
end
