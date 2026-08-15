require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
  end

  test "신규 사용자는 일반 사용자로 생성된다" do
    user = User.new

    assert_not user.admin?
  end

  test "테마는 지원하는 값만 설정할 수 있다" do
    @user.theme = "unsupported"

    assert_not @user.valid?
    assert @user.errors[:theme].present?
  end

  test "plugin_enabled?는 레코드가 없으면 true를 반환한다" do
    assert @user.plugin_enabled?(:posts)
  end

  test "plugin_enabled?는 비활성화된 플러그인에 false를 반환한다" do
    UserPlugin.create!(user: @user, plugin_name: "todos", enabled: false, disabled_at: Time.current)

    assert_not @user.plugin_enabled?(:todos)
  end

  test "plugin_enabled?는 심볼과 문자열 모두 지원한다" do
    UserPlugin.create!(user: @user, plugin_name: "todos", enabled: false, disabled_at: Time.current)

    assert_not @user.plugin_enabled?("todos")
    assert_not @user.plugin_enabled?(:todos)
  end

  test "enabled_plugins는 비활성 플러그인을 제외한다" do
    UserPlugin.create!(user: @user, plugin_name: "todos", enabled: false, disabled_at: Time.current)

    enabled = @user.enabled_plugins
    enabled_names = enabled.map(&:name)

    assert_not_includes enabled_names, :todos
    assert_includes enabled_names, :posts
  end

  test "approaching_deletion_plugins는 삭제 임박 플러그인을 반환한다" do
    UserPlugin.create!(user: @user, plugin_name: "todos", enabled: false, disabled_at: 25.days.ago)

    approaching = @user.approaching_deletion_plugins
    assert approaching.any? { |item| item[:plugin].name == :todos }
  end

  test "푸시 발송 요청과 대상 디바이스별 성공 결과를 기록한다" do
    registration = @user.push_registrations.create!(
      session: @user.sessions.create!,
      firebase_installation_id: "ios-installation-id",
      platform: "ios",
      device_model: "iPhone 17 Pro",
      os_version: "iOS 20.0",
      app_version: "1.2.3",
      last_registered_at: Time.current
    )

    stub_notification_sender(result: true) do
      assert @user.send_push_notification(
        title: "할 일 알림",
        body: "마감 시간이 다가옵니다.",
        url: "/todos/1",
        plugin_name: "todos",
        item_key: "due_date_reminder"
      )
    end

    notification_log = @user.push_notification_logs.last
    target = notification_log.targets.first

    assert_equal "sent", notification_log.status
    assert_equal "할 일 알림", notification_log.title
    assert_equal "todos", notification_log.plugin_name
    assert_equal registration.id, target["push_registration_id"]
    assert_equal "iPhone 17 Pro", target["device_model"]
    assert_equal "sent", target["status"]
  end

  test "무효 등록 삭제 후에도 대상 디바이스 스냅샷을 기록한다" do
    registration = @user.push_registrations.create!(
      session: @user.sessions.create!,
      firebase_installation_id: "invalid-installation-id",
      platform: "ios",
      app_version: "1.2.3",
      last_registered_at: Time.current
    )

    stub_notification_sender(error: Fcm::InvalidRegistrationError.new("UNREGISTERED")) do
      assert_not @user.send_push_notification(title: "제목", body: "내용")
    end

    notification_log = @user.push_notification_logs.last

    assert_equal "failed", notification_log.status
    assert_equal "invalid_registration", notification_log.targets.first["status"]
    assert_equal registration.id, notification_log.targets.first["push_registration_id"]
  end

  test "등록 디바이스가 없으면 대상 없음으로 기록한다" do
    assert_not @user.send_push_notification(title: "제목", body: "내용")

    notification_log = @user.push_notification_logs.last

    assert_equal "no_targets", notification_log.status
    assert_equal 0, notification_log.target_count
  end

  private

  def stub_notification_sender(result: nil, error: nil)
    original = Fcm::NotificationSender.instance_method(:call)
    Fcm::NotificationSender.define_method(:call) do |**|
      raise error if error

      result
    end
    yield
  ensure
    Fcm::NotificationSender.define_method(:call, original)
  end
end
