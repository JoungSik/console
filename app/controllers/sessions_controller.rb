class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: t("messages.errors.rate_limit_exceeded") }

  def new
  end

  def create
    if (user = User.authenticate_by(params.permit(:email_address, :password)))
      unless user.email_verified?
        RegistrationsMailer.verify(user).deliver_later
        redirect_to verify_pending_registration_path, alert: t("messages.errors.email_not_verified")
        return
      end

      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: t("messages.errors.invalid_credentials")
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
