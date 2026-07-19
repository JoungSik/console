class PluginDataDeletionJob < ApplicationJob
  queue_as :default

  def perform
    UserPlugin.pending_deletion.includes(:user).find_each do |user_plugin|
      plugin = PluginRegistry.find(user_plugin.plugin_name.to_sym)
      next unless plugin

      unless Console::PluginDataCleaner.clean_data_for(
        plugin_name: user_plugin.plugin_name,
        user_id: user_plugin.user_id
      )
        Rails.logger.error("플러그인 데이터 삭제 실패 [#{user_plugin.plugin_name}], user_id: #{user_plugin.user_id}")
        next
      end

      user_plugin.user.send_push_notification(
        title: I18n.t("settings.plugins.data_deleted", plugin: plugin.label),
        body: I18n.t("settings.plugins.data_deleted", plugin: plugin.label)
      )

      user_plugin.user.push_notification_settings.where(plugin_name: user_plugin.plugin_name).delete_all

      user_plugin.destroy!
    end
  end
end
