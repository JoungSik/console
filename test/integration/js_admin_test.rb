require "test_helper"

class JSAdminTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
  end

  test "비인증 사용자는 로그인 페이지로 이동한다" do
    get "/admin"

    assert_redirected_to Rails.application.routes.url_helpers.new_session_path
    assert_equal "http://www.example.com/admin/", session[:return_to_after_authenticating]
  end

  test "관리자는 어드민에 접근할 수 있다" do
    sign_in_as @user

    get "/admin"

    assert_response :success
    assert_select "a[href='/admin/user']"
    assert_select "a[href='/admin/user_plugin']"
    assert_select "a[href='/admin/push_notification_setting']"
    assert_select "a[href='/admin/push_subscription']"
    assert_select "a[href='/admin/todo--list']"
    assert_select "a[href='/admin/todo--item']"
    assert_select "a[href='/admin/journal--post']"
  end

  test "일반 사용자는 어드민에 접근할 수 없다" do
    sign_in_as users(:other_user)

    get "/admin"

    assert_response :forbidden
  end

  test "허용한 코어와 엔진 모델만 노출한다" do
    expected_model_names = [
      "Journal::Post",
      "PushNotificationSetting",
      "PushSubscription",
      "Todo::Item",
      "Todo::List",
      "User",
      "UserPlugin"
    ]

    assert_equal expected_model_names, JSAdmin.resources.map { |resource| resource.model_class.name }.sort
  end

  test "멀티 DB 엔진 모델 목록에 접근할 수 있다" do
    sign_in_as @user

    get "/admin/todo--list"
    assert_response :success

    get "/admin/journal--post"
    assert_response :success
  end

  test "Hotwire Native 비인증 요청은 401을 반환한다" do
    get "/admin", headers: { "User-Agent" => "Console Hotwire Native iOS" }

    assert_response :unauthorized
    assert_equal "http://www.example.com/admin/", session[:return_to_after_authenticating]
  end
end
