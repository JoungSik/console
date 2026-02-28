# 플러그인별 푸시 알림 항목 on/off 설정
class PushNotificationSetting < ApplicationRecord
  belongs_to :user

  validates :plugin_name, presence: true
  validates :item_key, presence: true
  validates :item_key, uniqueness: { scope: %i[user_id plugin_name] }

  scope :for_plugin, ->(plugin_name) { where(plugin_name: plugin_name) }
  scope :disabled, -> { where(enabled: false) }
end
