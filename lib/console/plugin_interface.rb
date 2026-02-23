# 플러그인이 코어 앱에 접근하기 위한 인터페이스
# 플러그인 컨트롤러에서 include하여 사용한다.
# User 모델을 직접 참조하지 않고 이 인터페이스를 통해서만 접근한다.
module Console
  module PluginInterface
    extend ActiveSupport::Concern

    included do
      before_action :verify_plugin_enabled
      helper_method :current_user_id, :current_user_name, :current_user_email
    end

    private

    # 비활성화된 플러그인 접근 차단
    def verify_plugin_enabled
      return unless current_user

      plugin = PluginRegistry.all.find { |p| request.path.start_with?(p.path) }
      return unless plugin

      unless current_user.plugin_enabled?(plugin.name)
        redirect_to main_app.root_path, alert: t("settings.plugins.disabled_access")
      end
    end

    def current_user_id
      current_user&.id
    end

    def current_user_name
      current_user&.name
    end

    def current_user_email
      current_user&.email_address
    end
  end
end
