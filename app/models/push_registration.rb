class PushRegistration < ApplicationRecord
  PLATFORMS = %w[web android ios].freeze

  belongs_to :user
  belongs_to :session

  encrypts :firebase_installation_id, deterministic: true

  validates :firebase_installation_id, presence: true, uniqueness: true
  validates :platform, inclusion: { in: PLATFORMS }
  validates :platform, uniqueness: { scope: :session_id }
  validates :last_registered_at, presence: true
  validate :session_matches_user

  def send_notification(title:, body:, url: nil, icon: nil)
    Fcm::NotificationSender.new(self).call(title:, body:, url:, icon:)
  rescue Fcm::InvalidRegistrationError
    destroy
    false
  rescue Fcm::Error => error
    Rails.logger.error("FCM notification failed: #{error.message}")
    false
  end

  private

  def session_matches_user
    return if session.nil? || user.nil? || session.user_id == user_id

    errors.add(:session, :user_mismatch)
  end
end
