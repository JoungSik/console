class Mypage::PushNotificationsController < Mypage::ApplicationController
  def show
    @firebase_web_configured = Fcm::Configuration.web_configured?
    @firebase_web_config = Fcm::Configuration.firebase_web_app
    @firebase_vapid_public_key = Fcm::Configuration.web[:vapid_public_key]
    @web_push_registration = Current.session.push_registrations.find_by(platform: "web")
    @native_push_registrations = Current.session.push_registrations
                                                .where(platform: %w[android ios])
                                                .index_by(&:platform)
    @notification_plugins = PluginRegistry.notification_plugins.select do |plugin|
      current_user.plugin_enabled?(plugin.name)
    end
    @push_notification_settings = current_user.push_notification_settings
                                              .index_by { |s| [ s.plugin_name, s.item_key ] }
  end

  def toggle
    plugin_name = params[:plugin_name]
    item_key = params[:item_key]

    plugin = PluginRegistry.find(plugin_name.to_sym)
    item = plugin&.push_notification_items&.find { |candidate| candidate.key == item_key }

    unless item
      return respond_with_error(t("settings.push_notifications.item_not_found"),
        redirect_url: mypage_push_notifications_path)
    end

    setting = current_user.push_notification_settings.find_or_initialize_by(
      plugin_name: plugin_name,
      item_key: item_key
    )
    setting.enabled = !setting.enabled
    setting.save!

    message = setting.enabled? ? t("settings.push_notifications.item_enabled") : t("settings.push_notifications.item_disabled")

    respond_to do |format|
      format.turbo_stream do
        @plugin = plugin
        @item = item
        @enabled = setting.enabled?
        flash.now[:notice] = message
      end
      format.html { redirect_to mypage_push_notifications_path, status: :see_other, notice: message }
    end
  end
end
