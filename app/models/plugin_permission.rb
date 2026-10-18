class PluginPermission < ApplicationRecord
  belongs_to :user

  validates :plugin_name, presence: true, uniqueness: { scope: :user_id }
  validate :plugin_must_be_restricted

  private

  def plugin_must_be_restricted
    errors.add(:plugin_name, :inclusion) unless PluginRegistry.find(plugin_name.to_s.to_sym)&.restricted?
  end
end
