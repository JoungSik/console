# 푸시 알림 설정 페이지 (플러그인별 알림 항목 on/off)
class Mypage::PushNotificationsController < Mypage::ApplicationController
  def show
    @notification_plugins = PluginRegistry.notification_plugins.select do |plugin|
      current_user.plugin_enabled?(plugin.name)
    end
    # N+1 쿼리 방지를 위해 알림 설정을 미리 로드
    @push_notification_settings = current_user.push_notification_settings
                                              .index_by { |s| [ s.plugin_name, s.item_key ] }
  end

  def toggle
    plugin_name = params[:plugin_name]
    item_key = params[:item_key]

    # 유효한 플러그인/항목인지 확인
    plugin = PluginRegistry.find(plugin_name.to_sym)
    unless plugin&.push_notification_items&.any? { |item| item.key == item_key }
      redirect_to mypage_push_notifications_path, alert: t("settings.push_notifications.item_not_found")
      return
    end

    setting = current_user.push_notification_settings.find_or_initialize_by(
      plugin_name: plugin_name,
      item_key: item_key
    )
    setting.enabled = !setting.enabled
    setting.save!

    message = setting.enabled? ? t("settings.push_notifications.item_enabled") : t("settings.push_notifications.item_disabled")
    redirect_to mypage_push_notifications_path, notice: message
  end
end
