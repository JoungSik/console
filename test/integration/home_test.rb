require "test_helper"

class HomeTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
  end

  test "인증된 사용자는 홈 화면에 접근할 수 있다" do
    sign_in_as @user
    get root_url
    assert_response :success
  end

  test "비인증 사용자에게 랜딩 페이지가 표시된다" do
    get root_url
    assert_response :success
    assert_select "h1", "Console"
  end

  test "Native 랜딩 페이지는 상단 여백 제거 계약을 제공한다" do
    get root_url, headers: { "User-Agent" => "Console Hotwire Native iOS" }

    assert_response :success
    assert_select "link[rel='stylesheet'][href*='hotwire_native']"
    assert_select "[data-native-top-flush]"
  end

  test "랜딩 페이지에 기능 소개와 CTA 링크가 있다" do
    get root_url
    assert_select "h3", "포스트"
    assert_select "h3", "할 일"
    assert_select "a[href='#{new_registration_path}']"
    assert_select "a[href='#{new_session_path}']"
  end

  test "대시보드에 지원되는 플러그인 위젯만 표시된다" do
    sign_in_as @user
    get root_url

    assert_response :success
    assert_select "h1", "대시보드"
    assert_select "h2", "할 일 목록"
    assert_select "h2", { text: "포스트", count: 0 }
  end

  test "대시보드 위젯에 전체보기 링크가 있다" do
    sign_in_as @user
    get root_url

    assert_select "a[href='#{todo.root_path}']", "전체보기"
    assert_select "a[href='#{posts.root_path}']", { text: "전체보기", count: 0 }
  end
end
