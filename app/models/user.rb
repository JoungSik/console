class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  has_many :push_subscriptions, dependent: :destroy
  has_many :user_plugins, dependent: :destroy

  # 사용자의 모든 구독으로 알림 전송 (하나라도 성공하면 true 반환)
  def send_push_notification(title:, body:, url: nil)
    sent_at_least_once = false
    push_subscriptions.find_each do |subscription|
      sent_at_least_once ||= subscription.send_notification(title: title, body: body, url: url)
    end
    sent_at_least_once
  end

  encrypts :email_address, deterministic: true
  encrypts :name

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  generates_token_for :email_verification, expires_in: 24.hours do
    email_address
  end

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 },
                       format: { with: /\A(?=.*[a-zA-Z])(?=.*\d)/,
                                 message: :password_complexity },
                       if: -> { password.present? }

  def email_verified?
    email_verified_at.present?
  end

  # 해당 플러그인이 활성화되어 있는지 확인 (레코드 없으면 기본 활성)
  def plugin_enabled?(plugin_name)
    !disabled_plugin_names.include?(plugin_name.to_s)
  end

  # 활성화된 플러그인 목록 반환
  def enabled_plugins
    PluginRegistry.all.reject { |p| disabled_plugin_names.include?(p.name.to_s) }
  end

  # 삭제 임박한 비활성 플러그인 (23~30일 경과)
  def approaching_deletion_plugins
    user_plugins.approaching_deletion.map do |up|
      plugin = PluginRegistry.find(up.plugin_name.to_sym)
      next unless plugin

      { plugin: plugin, days_until_deletion: up.days_until_deletion }
    end.compact
  end

  private

  def disabled_plugin_names
    @disabled_plugin_names ||= user_plugins.disabled.pluck(:plugin_name).to_set
  end
end
