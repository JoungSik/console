# 사용자별 플러그인 활성화/비활성화 상태 관리
class UserPlugin < ApplicationRecord
  belongs_to :user

  validates :plugin_name, presence: true, uniqueness: { scope: :user_id }

  scope :enabled, -> { where(enabled: true) }
  scope :disabled, -> { where(enabled: false) }
  scope :pending_deletion, -> { disabled.where(disabled_at: ..30.days.ago) }
  scope :approaching_deletion, -> { disabled.where(disabled_at: 30.days.ago..23.days.ago) }

  # 플러그인 비활성화
  def disable!
    update!(enabled: false, disabled_at: Time.current)
  end

  # 플러그인 활성화 (삭제 예약 취소)
  def enable!
    update!(enabled: true, disabled_at: nil)
  end

  # 삭제까지 남은 일수
  def days_until_deletion
    return nil unless disabled_at

    30 - ((Time.current - disabled_at) / 1.day).floor
  end
end
