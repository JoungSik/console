require "test_helper"

class Todo::ReminderJobTest < ActiveJob::TestCase
  setup do
    @user = users(:test_user)
    @list = Todo::List.create!(title: "테스트 목록", user_id: @user.id)
    @user.push_subscriptions.create!(
      endpoint: "https://push.example.com/test",
      p256dh_key: "test_p256dh_key",
      auth_key: "test_auth_key"
    )
  end

  test "오늘 마감만 있을 때 통합 알림을 발송한다" do
    @list.items.create!(title: "오늘 할 일 1", due_date: Date.current)
    @list.items.create!(title: "오늘 할 일 2", due_date: Date.current)

    notifications = capture_push_notifications do
      Todo::ReminderJob.perform_now
    end

    assert_equal 1, notifications.size
    assert_equal "할 일 리마인더", notifications.first[:title]
    assert_equal "오늘 마감인 할 일이 2개 있습니다", notifications.first[:body]
  end

  test "기한 초과만 있을 때 통합 알림을 발송한다" do
    @list.items.create!(title: "어제 할 일", due_date: 1.day.ago.to_date)
    @list.items.create!(title: "그제 할 일", due_date: 2.days.ago.to_date)

    notifications = capture_push_notifications do
      Todo::ReminderJob.perform_now
    end

    assert_equal 1, notifications.size
    assert_equal "할 일 리마인더", notifications.first[:title]
    assert_equal "기한이 초과된 할 일이 2개 있습니다", notifications.first[:body]
  end

  test "오늘 마감과 기한 초과 모두 있을 때 통합 알림을 발송한다" do
    @list.items.create!(title: "오늘 할 일", due_date: Date.current)
    @list.items.create!(title: "어제 할 일", due_date: 1.day.ago.to_date)

    notifications = capture_push_notifications do
      Todo::ReminderJob.perform_now
    end

    assert_equal 1, notifications.size
    assert_equal "할 일 리마인더", notifications.first[:title]
    assert_equal "오늘 마감 1개, 기한 초과 1개의 할 일이 있습니다", notifications.first[:body]
  end

  test "매일 반복 발송한다" do
    @list.items.create!(title: "오늘 할 일", due_date: Date.current)

    # 첫 번째 발송
    notifications1 = capture_push_notifications do
      Todo::ReminderJob.perform_now
    end

    # 두 번째 발송 (동일 항목에 대해 다시 발송)
    notifications2 = capture_push_notifications do
      Todo::ReminderJob.perform_now
    end

    assert_equal 1, notifications1.size
    assert_equal 1, notifications2.size
  end

  test "완료된 항목은 알림하지 않는다" do
    @list.items.create!(title: "완료된 할 일", due_date: Date.current, completed: true)

    notifications = capture_push_notifications do
      Todo::ReminderJob.perform_now
    end

    assert_empty notifications
  end

  test "마감일이 없는 항목은 알림하지 않는다" do
    @list.items.create!(title: "마감일 없는 할 일", due_date: nil)

    notifications = capture_push_notifications do
      Todo::ReminderJob.perform_now
    end

    assert_empty notifications
  end

  test "미래 마감일 항목은 알림하지 않는다" do
    @list.items.create!(title: "내일 할 일", due_date: 1.day.from_now.to_date)

    notifications = capture_push_notifications do
      Todo::ReminderJob.perform_now
    end

    assert_empty notifications
  end

  private

  # 푸시 알림 내용을 캡처하는 헬퍼
  def capture_push_notifications(&block)
    notifications = []
    original = PushSubscription.instance_method(:send_notification)
    PushSubscription.define_method(:send_notification) do |**kwargs|
      notifications << kwargs
      true
    end
    block.call
    notifications
  ensure
    PushSubscription.define_method(:send_notification, original)
  end
end
