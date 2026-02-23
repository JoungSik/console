# 플러그인 활성화/비활성화 설정 관리
class Mypage::PluginsController < Mypage::ApplicationController
  def index
    @plugins = PluginRegistry.all.map do |plugin|
      user_plugin = current_user.user_plugins.find_by(plugin_name: plugin.name.to_s)
      enabled = user_plugin.nil? || user_plugin.enabled?

      {
        plugin: plugin,
        enabled: enabled,
        days_until_deletion: user_plugin&.days_until_deletion
      }
    end
  end

  def toggle
    plugin_name = params[:id]

    unless PluginRegistry.registered?(plugin_name.to_sym)
      redirect_to mypage_plugins_path, alert: t("settings.plugins.not_found")
      return
    end

    user_plugin = current_user.user_plugins.find_or_initialize_by(plugin_name: plugin_name)
    plugin_label = PluginRegistry.find(plugin_name.to_sym).label

    if user_plugin.new_record? || user_plugin.enabled?
      user_plugin.plugin_name = plugin_name
      user_plugin.disable!
      redirect_to mypage_plugins_path, notice: t("settings.plugins.deactivated", plugin: plugin_label)
    else
      user_plugin.enable!
      redirect_to mypage_plugins_path, notice: t("settings.plugins.activated", plugin: plugin_label)
    end
  end
end
