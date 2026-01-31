# 마이페이지 컨트롤러
class Mypage::UsersController < Mypage::ApplicationController
  def show
  end

  def update
    unless current_user.authenticate(params[:user][:current_password])
      return redirect_to mypage_user_path, alert: t("settings.password.current_password_incorrect")
    end

    if current_user.update(user_params)
      terminate_session
      redirect_to new_session_path, notice: t("settings.password.updated_please_login")
    else
      redirect_to mypage_user_path, alert: current_user.errors.full_messages.join(", ")
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
