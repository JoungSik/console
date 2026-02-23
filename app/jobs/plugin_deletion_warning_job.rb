# 비활성화 후 23~30일 경과된 플러그인에 대해 삭제 경고 알림 발송
class PluginDeletionWarningJob < ApplicationJob
  queue_as :default

  def perform
    UserPlugin.approaching_deletion.includes(:user).find_each do |user_plugin|
      plugin = PluginRegistry.find(user_plugin.plugin_name.to_sym)
      next unless plugin

      days_left = user_plugin.days_until_deletion

      user_plugin.user.send_push_notification(
        title: I18n.t("settings.plugins.deletion_warning_title"),
        body: I18n.t("settings.plugins.deletion_warning_body", plugin: plugin.label, days: days_left),
        url: "/mypage/plugins"
      )
    end
  end
end
