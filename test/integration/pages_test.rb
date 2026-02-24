require "test_helper"

class PagesTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
  end

  test "미인증 사용자가 이용약관 페이지에 접근할 수 있다" do
    get terms_url
    assert_response :success
    assert_select "h1", I18n.t("pages.terms")
  end

  test "미인증 사용자가 개인정보처리방침 페이지에 접근할 수 있다" do
    get privacy_url
    assert_response :success
    assert_select "h1", I18n.t("pages.privacy")
  end

  test "인증된 사용자가 이용약관 페이지에 접근할 수 있다" do
    sign_in_as @user
    get terms_url
    assert_response :success
  end

  test "인증된 사용자가 개인정보처리방침 페이지에 접근할 수 있다" do
    sign_in_as @user
    get privacy_url
    assert_response :success
  end

  test "로그인 페이지에 이용약관 링크가 있다" do
    get new_session_url
    assert_response :success
    assert_select "a[href=?]", terms_path, text: I18n.t("pages.terms")
    assert_select "a[href=?]", privacy_path, text: I18n.t("pages.privacy")
  end
end
