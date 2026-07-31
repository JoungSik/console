JSAdmin.configure do |config|
  config.include_models "User",
    "UserPlugin",
    "PushNotificationSetting",
    "PushSubscription",
    "Todo::List",
    "Todo::Item",
    "Journal::Post"
  config.display_name_methods = %i[name title email_address body id]
end

Rails.application.config.to_prepare do
  JSAdmin::ApplicationController.include AdminAuthorization
end
