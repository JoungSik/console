require "test_helper"

class Mypage::PushNotificationsTest < ActionDispatch::IntegrationTest
  NATIVE_HEADERS = { "User-Agent" => "Console Hotwire Native iOS" }.freeze

  setup do
    @user = users(:test_user)
    sign_in_as @user
  end

  test "푸시 알림 설정 페이지에 접근할 수 있다" do
    get mypage_push_notifications_url
    assert_response :success
    assert_select "h1", I18n.t("settings.push_notifications.page_title")
    assert_select "[data-controller='web-push-subscription']", count: 1
    assert_select "[data-controller~='native-push-subscription']", count: 0
    assert_select "[data-web-push-subscription-firebase-config-value]", count: 1
    assert_select "[data-web-push-subscription-vapid-public-key-value]", count: 1
    assert_select "meta[name^='firebase-']", count: 0

    element = css_select("[data-web-push-subscription-status-messages-value]").first
    status_messages = JSON.parse(element["data-web-push-subscription-status-messages-value"])
    assert_equal I18n.t("settings.push_notifications.status.subscription_failed"),
      status_messages["subscription_failed"]
  end

  test "현재 Web 세션 등록 여부를 Web 구독 controller에 전달한다" do
    PushRegistration.create!(
      user: @user,
      session: Session.last,
      firebase_installation_id: "subscribed-web-installation-id",
      platform: "web",
      last_registered_at: Time.current
    )

    get mypage_push_notifications_url

    assert_response :success
    assert_select "[data-web-push-subscription-subscribed-value='true']", count: 1
    assert_select "[data-web-push-subscription-destroy-url-value='#{mypage_push_registration_path(PushRegistration.last)}']", count: 1
  end

  test "현재 Native 세션의 플랫폼별 member 삭제 URL을 전달한다" do
    registration = PushRegistration.create!(
      user: @user,
      session: Session.last,
      firebase_installation_id: "subscribed-ios-installation-id",
      platform: "ios",
      last_registered_at: Time.current
    )

    get mypage_push_notifications_url, headers: NATIVE_HEADERS

    assert_response :success
    element = css_select("[data-native-push-subscription-destroy-urls-value]").first
    destroy_urls = JSON.parse(element["data-native-push-subscription-destroy-urls-value"])
    assert_equal mypage_push_registration_path(registration), destroy_urls["ios"]
  end

  test "Native 요청에는 Native 구독 UI와 Bridge만 렌더링한다" do
    get mypage_push_notifications_url, headers: NATIVE_HEADERS

    assert_response :success
    assert_select "[data-controller~='native-push-subscription'][data-controller~='bridge--push-notification']", count: 1
    assert_select "[data-controller='web-push-subscription']", count: 0
    assert_select "[data-web-push-subscription-firebase-config-value]", count: 0

    element = css_select("[data-native-push-subscription-status-messages-value]").first
    status_messages = JSON.parse(element["data-native-push-subscription-status-messages-value"])
    assert_equal I18n.t("settings.push_notifications.status.native_unavailable"),
      status_messages["native_unavailable"]
  end

  test "알림 항목이 있는 플러그인이 표시된다" do
    get mypage_push_notifications_url
    assert_response :success

    assert_select "h2", "할 일 목록"
  end

  test "알림 항목을 비활성화할 수 있다" do
    patch toggle_mypage_push_notifications_url(plugin_name: "todos", item_key: "due_date_reminder")
    assert_response :see_other
    assert_redirected_to mypage_push_notifications_url

    setting = @user.push_notification_settings.find_by(plugin_name: "todos", item_key: "due_date_reminder")
    assert_not setting.enabled?
  end

  test "비활성화된 알림 항목을 다시 활성화할 수 있다" do
    PushNotificationSetting.create!(user: @user, plugin_name: "todos", item_key: "due_date_reminder", enabled: false)

    patch toggle_mypage_push_notifications_url(plugin_name: "todos", item_key: "due_date_reminder")
    assert_response :see_other
    assert_redirected_to mypage_push_notifications_url

    setting = @user.push_notification_settings.find_by(plugin_name: "todos", item_key: "due_date_reminder")
    assert setting.enabled?
  end

  test "존재하지 않는 알림 항목은 토글할 수 없다" do
    patch toggle_mypage_push_notifications_url(plugin_name: "todos", item_key: "nonexistent")
    assert_response :see_other
    assert_redirected_to mypage_push_notifications_url
    assert_equal I18n.t("settings.push_notifications.item_not_found"), flash[:alert]
  end

  test "존재하지 않는 플러그인의 알림 항목은 토글할 수 없다" do
    patch toggle_mypage_push_notifications_url(plugin_name: "nonexistent", item_key: "some_key")
    assert_response :see_other
    assert_redirected_to mypage_push_notifications_url
    assert_equal I18n.t("settings.push_notifications.item_not_found"), flash[:alert]
  end

  test "Turbo Stream 토글은 알림 항목과 flash만 교체한다" do
    patch toggle_mypage_push_notifications_url(plugin_name: "todos", item_key: "due_date_reminder"),
      headers: turbo_stream_headers

    assert_response :success
    assert_select "turbo-stream[action='replace'][target='notification_todos_due_date_reminder']"
    assert_select "turbo-stream[action='update'][target='flash']"
  end

  test "Turbo Stream의 잘못된 알림 항목은 flash만 422로 갱신한다" do
    patch toggle_mypage_push_notifications_url(plugin_name: "todos", item_key: "nonexistent"),
      headers: turbo_stream_headers

    assert_response :unprocessable_entity
    assert_select "turbo-stream[action='update'][target='flash']"
    assert_select "turbo-stream[action='replace']", count: 0
  end

  test "비활성화된 플러그인의 알림은 표시되지 않는다" do
    UserPlugin.create!(user: @user, plugin_name: "todos", enabled: false, disabled_at: Time.current)

    get mypage_push_notifications_url
    assert_response :success
    assert_select "h2", { text: "할 일 목록", count: 0 }
  end
end
