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

  test "마감일 당일 항목에 알림을 발송하고 reminder_sent를 업데이트한다" do
    item = @list.items.create!(title: "오늘 할 일", due_date: Date.current, reminder_sent: false)

    stub_push_notification do
      Todo::ReminderJob.perform_now
    end

    assert item.reload.reminder_sent
  end

  test "기한 초과 항목에 알림을 발송하고 reminder_sent를 업데이트한다" do
    item = @list.items.create!(title: "어제 할 일", due_date: 1.day.ago.to_date, reminder_sent: false)

    stub_push_notification do
      Todo::ReminderJob.perform_now
    end

    assert item.reload.reminder_sent
  end

  test "이미 reminder_sent인 항목은 중복 발송하지 않는다" do
    item = @list.items.create!(title: "알림 발송 완료", due_date: Date.current, reminder_sent: true)
    original_updated_at = item.updated_at

    stub_push_notification do
      Todo::ReminderJob.perform_now
    end

    # reminder_sent가 이미 true이므로 쿼리에서 제외되어 update_all이 호출되지 않음
    assert item.reload.reminder_sent
    assert_equal original_updated_at, item.updated_at
  end

  test "완료된 항목은 알림하지 않는다" do
    item = @list.items.create!(title: "완료된 할 일", due_date: Date.current, completed: true, reminder_sent: false)

    stub_push_notification do
      Todo::ReminderJob.perform_now
    end

    assert_not item.reload.reminder_sent
  end

  test "마감일이 없는 항목은 알림하지 않는다" do
    item = @list.items.create!(title: "마감일 없는 할 일", due_date: nil, reminder_sent: false)

    stub_push_notification do
      Todo::ReminderJob.perform_now
    end

    assert_not item.reload.reminder_sent
  end

  test "여러 항목이 있으면 복수 메시지를 발송한다" do
    @list.items.create!(title: "할 일 1", due_date: Date.current, reminder_sent: false)
    @list.items.create!(title: "할 일 2", due_date: Date.current, reminder_sent: false)

    stub_push_notification do
      Todo::ReminderJob.perform_now
    end

    assert_equal 2, @list.items.where(reminder_sent: true).count
  end

  test "알림 전송 실패 시 reminder_sent를 업데이트하지 않는다" do
    item = @list.items.create!(title: "오늘 할 일", due_date: Date.current, reminder_sent: false)

    # 구독 없는 사용자는 send_push_notification이 false 반환
    @user.push_subscriptions.destroy_all

    Todo::ReminderJob.perform_now

    assert_not item.reload.reminder_sent
  end

  private

  # 실제 Push 전송을 방지하고 성공 반환
  def stub_push_notification(&block)
    original = PushSubscription.instance_method(:send_notification)
    PushSubscription.define_method(:send_notification) { |**| true }
    block.call
  ensure
    PushSubscription.define_method(:send_notification, original)
  end
end
