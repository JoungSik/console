class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]
  rate_limit to: 5, within: 3.minutes, only: :create,
    with: -> { redirect_to new_password_url, alert: t("messages.errors.rate_limit_exceeded") }

  def new
  end

  def create
    if (user = User.find_by(email_address: params[:email_address]))
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_session_path, notice: t("messages.success.password_reset_instructions_sent")
  end

  def edit
  end

  def update
    if @user.update(params.permit(:password, :password_confirmation))
      start_new_session_for(@user)
      redirect_to after_authentication_url, notice: t("messages.success.password_updated")
    else
      redirect_to edit_password_path(params[:token]), alert: t("messages.errors.passwords_did_not_match")
    end
  end

  private

  def set_user_by_token
    @user = User.find_by_password_reset_token!(params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_password_path, alert: t("messages.errors.password_reset_link_invalid")
  end
end
