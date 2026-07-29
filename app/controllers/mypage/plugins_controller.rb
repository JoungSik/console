class Mypage::PluginsController < Mypage::ApplicationController
  def index
    user_plugins_map = current_user.user_plugins.index_by(&:plugin_name)
    @plugins = PluginRegistry.all.map { |plugin| plugin_item(plugin, user_plugins_map[plugin.name.to_s]) }
  end

  def toggle
    plugin_name = params[:id]

    unless PluginRegistry.registered?(plugin_name.to_sym)
      return respond_with_error(t("settings.plugins.not_found"), redirect_url: mypage_plugins_path)
    end

    user_plugin = current_user.user_plugins.find_or_initialize_by(plugin_name: plugin_name)
    plugin = PluginRegistry.find(plugin_name.to_sym)

    if user_plugin.new_record? || user_plugin.enabled?
      user_plugin.plugin_name = plugin_name
      user_plugin.disable!
      message = t("settings.plugins.deactivated", plugin: plugin.label)
    else
      user_plugin.enable!
      message = t("settings.plugins.activated", plugin: plugin.label)
    end

    respond_to do |format|
      format.turbo_stream do
        @item = plugin_item(plugin, user_plugin)
        flash.now[:notice] = message
      end
      format.html { redirect_to mypage_plugins_path, status: :see_other, notice: message }
    end
  end

  private

  def plugin_item(plugin, user_plugin)
    {
      plugin: plugin,
      enabled: user_plugin.nil? || user_plugin.enabled?,
      days_until_deletion: user_plugin&.days_until_deletion
    }
  end
end
