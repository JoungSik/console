require "test_helper"

class SessionsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
  end

  test "로그인 페이지에 접근할 수 있다" do
    get new_session_url
    assert_response :success
    assert_select "nav[aria-label='Sidebar']", count: 0
  end

  test "올바른 자격증명으로 로그인하면 root_path로 리다이렉트된다" do
    post session_url, params: { email_address: @user.email_address, password: "password123" }
    assert_response :see_other
    assert_redirected_to root_url
    follow_redirect!
    assert_response :success
  end

  test "잘못된 비밀번호로 로그인하면 실패한다" do
    post session_url, params: { email_address: @user.email_address, password: "wrong" }
    assert_response :unprocessable_entity
    assert_select "#flash", text: /#{I18n.t("messages.errors.invalid_credentials")}/
    assert_select "input[name='email_address'][value=?]", @user.email_address
  end

  test "존재하지 않는 이메일로 로그인하면 실패한다" do
    post session_url, params: { email_address: "nobody@example.com", password: "password123" }
    assert_response :unprocessable_entity
    assert_select "#flash", text: /#{I18n.t("messages.errors.invalid_credentials")}/
    assert_select "input[name='email_address'][value='nobody@example.com']"
  end

  test "로그아웃하면 new_session_path로 리다이렉트된다" do
    sign_in_as @user
    delete session_url
    assert_response :see_other
    assert_redirected_to new_session_path
  end

  test "비인증 상태에서 보호된 페이지에 접근하면 로그인 페이지로 리다이렉트된다" do
    get mypage_user_url
    assert_redirected_to new_session_path
  end

  test "Hotwire Native 미인증 요청은 복귀 URL을 보존하고 401을 반환한다" do
    get mypage_user_url, headers: { "User-Agent" => "Console Hotwire Native iOS" }

    assert_response :unauthorized
    assert_equal mypage_user_url, session[:return_to_after_authenticating]
  end

  test "기존 Turbo Native 미인증 요청도 401을 반환한다" do
    get mypage_user_url, headers: { "User-Agent" => "Console Turbo Native Android" }

    assert_response :unauthorized
  end

  test "인증된 Native 화면에는 웹 내비게이션 대신 Bridge 메뉴 계약이 표시된다" do
    sign_in_as @user

    get root_url, headers: { "User-Agent" => "Console Hotwire Native Android" }

    assert_response :success
    assert_select "nav[data-controller='bridge--menu'][aria-hidden='true']"
    assert_select "nav[aria-label='Sidebar']", count: 0
    assert_select ".fixed.bottom-0", count: 0
  end
end
