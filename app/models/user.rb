class User < ApplicationRecord
  enum :theme, { system: "system", light: "light", dark: "dark" }, prefix: true, validate: true

  has_secure_password
  has_many :sessions, dependent: :destroy

  has_many :push_registrations, dependent: :destroy
  has_many :push_notification_logs, dependent: :destroy
  has_many :user_plugins, dependent: :destroy
  has_many :push_notification_settings, dependent: :destroy

  def send_push_notification(title:, body:, url: nil, plugin_name: nil, item_key: nil)
    if plugin_name
      return false unless plugin_enabled?(plugin_name)
      return false if item_key && !push_notification_enabled?(plugin_name, item_key)
    end

    notification_log = push_notification_logs.create!(
      title: title,
      body: body,
      url: url,
      plugin_name: plugin_name,
      item_key: item_key,
      requested_at: Time.current
    )
    targets = push_registrations.find_each.map do |registration|
      target = registration.notification_target_snapshot
      sent = registration.send_notification(title: title, body: body, url: url)
      status = if sent
        "sent"
      elsif registration.destroyed?
        "invalid_registration"
      else
        "failed"
      end

      target.merge(status: status)
    end

    notification_log.complete!(targets: targets)
    notification_log.success_count.positive?
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
                       format: { with: /\A(?=.*[a-zA-Z])(?=.*\d).*\z/,
                                 message: :password_complexity },
                       if: -> { password.present? }

  def email_verified?
    email_verified_at.present?
  end

  def push_notification_enabled?(plugin_name, item_key)
    setting = push_notification_settings.find_by(plugin_name: plugin_name, item_key: item_key)
    setting.nil? || setting.enabled?
  end

  def plugin_enabled?(plugin_name)
    !disabled_plugin_names.include?(plugin_name.to_s)
  end

  def enabled_plugins
    PluginRegistry.all.reject { |p| disabled_plugin_names.include?(p.name.to_s) }
  end

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
