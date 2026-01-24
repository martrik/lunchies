class CalendarConnection < ApplicationRecord
  belongs_to :user

  encrypts :access_token
  encrypts :refresh_token

  def expired?
    expires_at.nil? || expires_at < Time.current
  end

  def valid_token?
    !expired? && access_token.present?
  end

  def refresh_access_token!
    return if refresh_token.blank?

    client = Google::Auth::UserRefreshCredentials.new(
      client_id: Rails.application.credentials.dig(:google, :client_id),
      client_secret: Rails.application.credentials.dig(:google, :client_secret),
      refresh_token: refresh_token
    )

    client.fetch_access_token!
    expires_in = client.expires_in || 3600
    update!(
      access_token: client.access_token,
      expires_at: Time.current + expires_in.seconds
    )
  end
end
