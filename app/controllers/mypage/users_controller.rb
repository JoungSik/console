class Mypage::UsersController < Mypage::ApplicationController
  def show
  end

  def update
    unless current_user.authenticate(params[:user][:current_password])
      flash.now[:alert] = t("settings.password.current_password_incorrect")
      return render :show, status: :unprocessable_entity
    end

    if current_user.update(user_params)
      terminate_session
      redirect_to new_session_path, status: :see_other, notice: t("settings.password.updated_please_login")
    else
      flash.now[:alert] = current_user.errors.full_messages.join(", ")
      render :show, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
