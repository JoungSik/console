require "test_helper"

class PushNotificationLogTest < ActiveSupport::TestCase
  setup do
    @notification_log = PushNotificationLog.create!(
      user: users(:test_user),
      title: "제목",
      body: "내용",
      requested_at: Time.current
    )
  end

  test "모든 대상 발송 성공을 기록한다" do
    targets = [
      { push_registration_id: 1, platform: "ios", status: "sent" },
      { push_registration_id: 2, platform: "web", status: "sent" }
    ]

    @notification_log.complete!(targets: targets)

    assert_equal "sent", @notification_log.status
    assert_equal 2, @notification_log.target_count
    assert_equal 2, @notification_log.success_count
    assert_equal 0, @notification_log.failure_count
    assert_equal 2, @notification_log.targets.size
    assert_not_nil @notification_log.completed_at
  end

  test "일부 대상 발송 실패를 기록한다" do
    targets = [
      { push_registration_id: 1, platform: "ios", status: "sent" },
      { push_registration_id: 2, platform: "web", status: "failed" }
    ]

    @notification_log.complete!(targets: targets)

    assert_equal "partially_failed", @notification_log.status
    assert_equal 1, @notification_log.success_count
    assert_equal 1, @notification_log.failure_count
  end

  test "발송 대상이 없음을 기록한다" do
    @notification_log.complete!(targets: [])

    assert_equal "no_targets", @notification_log.status
    assert_equal 0, @notification_log.target_count
  end
end
