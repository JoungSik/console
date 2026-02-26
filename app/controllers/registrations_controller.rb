class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  layout "blank"
  rate_limit to: 5, within: 3.minutes, only: :create, with: -> { redirect_to new_registration_url, alert: t("messages.errors.rate_limit_exceeded") }

  def new
    @user = User.new
  end

  def create
    unless params[:terms_agreed] == "1"
      @user = User.new(registration_params)
      flash.now[:alert] = t("messages.errors.terms_must_be_agreed")
      return render :new, status: :unprocessable_entity
    end

    @user = User.new(registration_params)

    if @user.save
      RegistrationsMailer.verify(@user).deliver_later
      redirect_to verify_pending_registration_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def verify_pending
  end

  def verify
    user = User.find_by_token_for(:email_verification, params[:token])

    if user
      if user.email_verified?
        redirect_to new_session_path, notice: t("messages.success.email_already_verified")
      else
        user.update!(email_verified_at: Time.current)
        start_new_session_for user
        redirect_to root_path, notice: t("messages.success.registration_verify_email_sent")
      end
    else
      redirect_to new_session_path, alert: t("messages.errors.email_verification_link_invalid")
    end
  end

  private

  def registration_params
    params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
  end
end
