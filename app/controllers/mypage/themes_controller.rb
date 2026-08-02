class Mypage::ThemesController < Mypage::ApplicationController
  def update
    if current_user.update(theme: params.dig(:theme, :value))
      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = t("settings.theme.updated") }
        format.html do
          redirect_to mypage_user_path, status: :see_other, notice: t("settings.theme.updated")
        end
      end
    else
      respond_with_error(current_user.errors.full_messages.join(", "), redirect_url: mypage_user_path)
    end
  end
end
