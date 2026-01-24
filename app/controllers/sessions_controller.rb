class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new callback ]

  def new
  end

  def callback
    gs = flash[:google_sign_in] || flash["google_sign_in"]
    id_token = gs&.[](:id_token) || gs&.[]("id_token")
    error = gs&.[](:error) || gs&.[]("error")

    if id_token.present?
      identity = GoogleSignIn::Identity.new(id_token)
      user = find_or_create_user_for_identity(identity)
      if user
        start_new_session_for user
        redirect_to after_authentication_url
      else
        redirect_to new_session_path, alert: "Sign-in failed. That email is already in use."
      end
    elsif error.present?
      Rails.logger.error "Google Sign-In error: #{error}"
      redirect_to new_session_path, alert: "Sign-in with Google failed. Please try again."
    else
      redirect_to new_session_path, alert: "Sign-in with Google failed. Please try again."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end

  private

  def find_or_create_user_for_identity(identity)
    user = User.find_by(google_id: identity.user_id)
    return user if user

    User.transaction do
      User.create!(
        email_address: identity.email_address,
        google_id: identity.user_id
      )
    end
  rescue ActiveRecord::RecordNotUnique
    existing = User.find_by(email_address: identity.email_address)
    return nil unless existing

    existing.update!(google_id: identity.user_id)
    existing
  end
end
