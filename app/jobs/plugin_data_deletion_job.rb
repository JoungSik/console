# 비활성화 후 30일 경과된 플러그인의 데이터를 삭제
class PluginDataDeletionJob < ApplicationJob
  queue_as :default

  def perform
    UserPlugin.pending_deletion.includes(:user).find_each do |user_plugin|
      plugin = PluginRegistry.find(user_plugin.plugin_name.to_sym)
      next unless plugin

      # 플러그인 데이터 삭제
      unless Console::PluginDataCleaner.clean_data_for(
        plugin_name: user_plugin.plugin_name,
        user_id: user_plugin.user_id
      )
        Rails.logger.error("플러그인 데이터 삭제 실패 [#{user_plugin.plugin_name}], user_id: #{user_plugin.user_id}")
        next
      end

      # 삭제 완료 알림
      user_plugin.user.send_push_notification(
        title: I18n.t("settings.plugins.data_deleted", plugin: plugin.label),
        body: I18n.t("settings.plugins.data_deleted", plugin: plugin.label)
      )

      # 해당 플러그인의 알림 설정 정리
      user_plugin.user.push_notification_settings.where(plugin_name: user_plugin.plugin_name).delete_all

      # user_plugin 레코드 삭제
      user_plugin.destroy!
    end
  end
end
