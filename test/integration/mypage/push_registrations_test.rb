require "test_helper"

class Mypage::PushRegistrationsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
    sign_in_as @user
    @registration_params = {
      push_registration: {
        firebase_installation_id: "test-installation-id",
        platform: "web"
      }
    }
  end

  test "FCM 등록을 생성할 수 있다" do
    assert_difference "PushRegistration.count", 1 do
      post mypage_push_registrations_url, params: @registration_params, as: :json
    end

    assert_response :created
    assert_equal "registered", response.parsed_body["status"]
    assert_equal mypage_push_registration_path(PushRegistration.last), response.parsed_body["destroy_url"]
    assert_equal @user, PushRegistration.last.user
    assert_equal Session.last, PushRegistration.last.session
  end

  test "같은 firebase_installation_id를 다시 등록하면 최근 등록 시각을 갱신한다" do
    post mypage_push_registrations_url, params: @registration_params, as: :json
    registration = PushRegistration.last
    registration.update_column(:last_registered_at, 2.days.ago)

    assert_no_difference "PushRegistration.count" do
      post mypage_push_registrations_url, params: @registration_params, as: :json
    end

    assert_response :created
    assert_in_delta Time.current, registration.reload.last_registered_at, 2.seconds
  end

  test "같은 세션과 플랫폼의 새 firebase_installation_id는 기존 등록을 교체한다" do
    post mypage_push_registrations_url, params: @registration_params, as: :json

    replacement_params = {
      push_registration: {
        firebase_installation_id: "replacement-installation-id",
        platform: "web"
      }
    }

    assert_no_difference "PushRegistration.count" do
      post mypage_push_registrations_url, params: replacement_params, as: :json
    end

    assert_response :created
    assert_nil PushRegistration.find_by(firebase_installation_id: "test-installation-id")
    assert_equal Session.last, PushRegistration.find_by!(firebase_installation_id: "replacement-installation-id").session
  end

  test "같은 기기에서 다른 사용자가 로그인하면 등록 소유권을 이전한다" do
    other_user = users(:other_user)
    registration = PushRegistration.create!(
      user: other_user,
      session: other_user.sessions.create!,
      firebase_installation_id: @registration_params.dig(:push_registration, :firebase_installation_id),
      platform: "ios",
      last_registered_at: 1.day.ago
    )

    assert_no_difference "PushRegistration.count" do
      post mypage_push_registrations_url, params: @registration_params, as: :json
    end

    assert_equal @user, registration.reload.user
    assert_equal "web", registration.platform
  end

  test "현재 세션의 FCM 등록을 삭제할 수 있다" do
    post mypage_push_registrations_url, params: @registration_params, as: :json
    registration = PushRegistration.last

    assert_difference "PushRegistration.count", -1 do
      delete mypage_push_registration_url(registration), as: :json
    end

    assert_response :ok
    assert_equal "unregistered", response.parsed_body["status"]
  end

  test "다른 세션의 FCM 등록은 삭제할 수 없다" do
    other_session = @user.sessions.create!
    registration = PushRegistration.create!(
      user: @user,
      session: other_session,
      firebase_installation_id: "other-session-installation-id",
      platform: "ios",
      last_registered_at: Time.current
    )

    delete mypage_push_registration_url(registration), as: :json

    assert_response :not_found
    assert_equal "not_found", response.parsed_body["error"]
  end
end
