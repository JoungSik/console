require "test_helper"

class PushRegistrationTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
    @session = @user.sessions.create!
    @registration = PushRegistration.create!(
      user: @user,
      session: @session,
      firebase_installation_id: "test-installation-id",
      platform: "web",
      last_registered_at: Time.current
    )
  end

  test "지원 플랫폼별 FCM 등록을 저장할 수 있다" do
    %w[web android ios].each do |platform|
      registration = PushRegistration.new(
        user: @user,
        session: @user.sessions.create!,
        firebase_installation_id: "#{platform}-installation-id",
        platform: platform,
        last_registered_at: Time.current
      )

      assert registration.valid?
    end
  end

  test "한 세션에는 플랫폼별 FCM 등록이 하나만 존재할 수 있다" do
    duplicate_platform = PushRegistration.new(
      user: @user,
      session: @session,
      firebase_installation_id: "another-web-installation-id",
      platform: "web",
      last_registered_at: Time.current
    )

    assert_not duplicate_platform.valid?
  end

  test "지원하지 않는 플랫폼은 저장할 수 없다" do
    @registration.platform = "desktop"

    assert_not @registration.valid?
  end

  test "firebase_installation_id는 중복될 수 없다" do
    duplicate = PushRegistration.new(
      user: @user,
      session: @session,
      firebase_installation_id: @registration.firebase_installation_id,
      platform: "web",
      last_registered_at: Time.current
    )

    assert_not duplicate.valid?
  end

  test "다른 사용자의 세션을 연결할 수 없다" do
    @registration.session = users(:other_user).sessions.create!

    assert_not @registration.valid?
    assert_includes @registration.errors[:session],
      I18n.t("activerecord.errors.models.push_registration.attributes.session.user_mismatch")
  end

  test "FCM 발송 성공 시 등록을 유지한다" do
    stub_notification_sender(result: true) do
      assert_no_difference "PushRegistration.count" do
        assert @registration.send_notification(title: "제목", body: "내용")
      end
    end
  end

  test "무효 FCM 등록은 삭제한다" do
    stub_notification_sender(error: Fcm::InvalidRegistrationError.new("UNREGISTERED")) do
      assert_difference "PushRegistration.count", -1 do
        assert_not @registration.send_notification(title: "제목", body: "내용")
      end
    end
  end

  test "일시적인 FCM 오류는 등록을 유지한다" do
    stub_notification_sender(error: Fcm::Error.new("UNAVAILABLE")) do
      assert_no_difference "PushRegistration.count" do
        assert_not @registration.send_notification(title: "제목", body: "내용")
      end
    end
  end

  test "웹 푸시 대상 스냅샷은 브라우저를 디바이스 모델로 포함한다" do
    @registration.update!(device_model: "Safari", os_version: "26.0")

    snapshot = @registration.notification_target_snapshot

    assert_equal "Safari", snapshot[:device_model]
    assert_equal "26.0", snapshot[:os_version]
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
