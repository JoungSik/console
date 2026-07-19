# 플러그인이 코어 User 모델에 직접 의존하지 않도록 제공하는 접근 인터페이스이다.
module Console
  module PluginInterface
    extend ActiveSupport::Concern

    included do
      before_action :verify_plugin_enabled
      helper_method :current_user_id, :current_user_name, :current_user_email
    end

    private

    def verify_plugin_enabled
      return unless current_user

      plugin = PluginRegistry.all.sort_by { |p| -p.path.length }.find { |p| request.path.start_with?(p.path) }
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
