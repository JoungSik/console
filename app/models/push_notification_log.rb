class PushNotificationLog < ApplicationRecord
  STATUSES = %w[pending sent partially_failed failed no_targets].freeze

  belongs_to :user

  encrypts :title
  encrypts :body
  encrypts :url

  validates :status, inclusion: { in: STATUSES }
  validates :title, :body, :requested_at, presence: true
  validates :target_count, :success_count, :failure_count,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def complete!(targets:)
    successful_count = targets.count { |target| target[:status] == "sent" }
    failed_count = targets.size - successful_count

    update!(
      targets: targets,
      target_count: targets.size,
      success_count: successful_count,
      failure_count: failed_count,
      status: completed_status(targets.size, successful_count),
      completed_at: Time.current
    )
  end

  private

  def completed_status(target_count, successful_count)
    return "no_targets" if target_count.zero?
    return "failed" if successful_count.zero?
    return "sent" if successful_count == target_count

    "partially_failed"
  end
end
