JSAdmin.configure do |config|
  config.include_models "User",
    "UserPlugin",
    "PluginPermission",
    "PushNotificationLog",
    "PushNotificationSetting",
    "PushRegistration",
    "Todo::List",
    "Todo::Item",
    "Journal::Post",
    "Inspiration::Idea",
    "Inspiration::Note"
  config.display_name_methods = %i[name title email_address body id]
  config.select_options "PluginPermission",
    plugin_name: -> { PluginRegistry.restricted_plugins.map { |plugin| [ plugin.label, plugin.name.to_s ] } }
end

Rails.application.config.to_prepare do
  JSAdmin::ApplicationController.include AdminAuthorization
end
