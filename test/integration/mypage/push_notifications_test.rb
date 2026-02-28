require "test_helper"

class Mypage::PushNotificationsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
    sign_in_as @user
  end

  test "푸시 알림 설정 페이지에 접근할 수 있다" do
    get mypage_push_notifications_url
    assert_response :success
    assert_select "h1", I18n.t("settings.push_notifications.page_title")
  end

  test "알림 항목이 있는 플러그인이 표시된다" do
    get mypage_push_notifications_url
    assert_response :success

    # Todo 플러그인에 알림 항목이 등록되어 있으므로 표시되어야 함
    assert_select "h2", "할 일 목록"
  end

  test "알림 항목을 비활성화할 수 있다" do
    patch toggle_mypage_push_notifications_url(plugin_name: "todos", item_key: "due_date_reminder")
    assert_redirected_to mypage_push_notifications_url

    setting = @user.push_notification_settings.find_by(plugin_name: "todos", item_key: "due_date_reminder")
    assert_not setting.enabled?
  end

  test "비활성화된 알림 항목을 다시 활성화할 수 있다" do
    PushNotificationSetting.create!(user: @user, plugin_name: "todos", item_key: "due_date_reminder", enabled: false)

    patch toggle_mypage_push_notifications_url(plugin_name: "todos", item_key: "due_date_reminder")
    assert_redirected_to mypage_push_notifications_url

    setting = @user.push_notification_settings.find_by(plugin_name: "todos", item_key: "due_date_reminder")
    assert setting.enabled?
  end

  test "존재하지 않는 알림 항목은 토글할 수 없다" do
    patch toggle_mypage_push_notifications_url(plugin_name: "todos", item_key: "nonexistent")
    assert_redirected_to mypage_push_notifications_url
    assert_equal I18n.t("settings.push_notifications.item_not_found"), flash[:alert]
  end

  test "존재하지 않는 플러그인의 알림 항목은 토글할 수 없다" do
    patch toggle_mypage_push_notifications_url(plugin_name: "nonexistent", item_key: "some_key")
    assert_redirected_to mypage_push_notifications_url
    assert_equal I18n.t("settings.push_notifications.item_not_found"), flash[:alert]
  end

  test "비활성화된 플러그인의 알림은 표시되지 않는다" do
    UserPlugin.create!(user: @user, plugin_name: "todos", enabled: false, disabled_at: Time.current)

    get mypage_push_notifications_url
    assert_response :success
    assert_select "h2", { text: "할 일 목록", count: 0 }
  end
end
