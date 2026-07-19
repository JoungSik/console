class UserPlugin < ApplicationRecord
  DELETION_GRACE_PERIOD_DAYS = 30
  DELETION_WARNING_START_DAYS = 23

  belongs_to :user

  validates :plugin_name, presence: true, uniqueness: { scope: :user_id }

  scope :enabled, -> { where(enabled: true) }
  scope :disabled, -> { where(enabled: false) }
  scope :pending_deletion, -> { disabled.where(disabled_at: ..DELETION_GRACE_PERIOD_DAYS.days.ago) }
  scope :approaching_deletion, -> { disabled.where(disabled_at: DELETION_GRACE_PERIOD_DAYS.days.ago..DELETION_WARNING_START_DAYS.days.ago) }

  def disable!
    update!(enabled: false, disabled_at: Time.current)
  end

  def enable!
    update!(enabled: true, disabled_at: nil)
  end

  def days_until_deletion
    return nil unless disabled_at

    DELETION_GRACE_PERIOD_DAYS - ((Time.current - disabled_at) / 1.day).floor
  end
end
