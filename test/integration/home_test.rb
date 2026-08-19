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

  test "대시보드에는 노출 기간인 공지만 순서대로 표시된다" do
    second = create_notice(title: "두 번째 공지", body: "두 번째 내용", position: 20)
    first = create_notice(title: "첫 번째 공지", body: "첫 번째 내용", position: 10)
    create_notice(title: "게시 전 공지", published_on: Date.current.tomorrow)
    create_notice(
      title: "만료된 공지",
      published_on: Date.current - 2.days,
      expires_on: Date.current.yesterday
    )

    sign_in_as @user
    get root_url

    assert_select "#dashboard-notices article", count: 2
    assert_select "##{dom_id(first)} a[href='#{notice_path(first)}']", "첫 번째 공지"
    assert_select "##{dom_id(second)} a[href='#{notice_path(second)}']", "두 번째 공지"
    assert_operator response.body.index(dom_id(first)), :<, response.body.index(dom_id(second))
    assert_no_match "첫 번째 내용", response.body
    assert_no_match "두 번째 내용", response.body
    assert_no_match "게시 전 공지", response.body
    assert_no_match "만료된 공지", response.body
  end

  test "공지는 삭제 예정 배너와 대시보드 위젯보다 먼저 표시된다" do
    create_notice(title: "상단 공지")
    UserPlugin.create!(
      user: @user,
      plugin_name: "posts",
      enabled: false,
      disabled_at: 25.days.ago
    )

    sign_in_as @user
    get root_url

    notice_position = response.body.index("dashboard-notices")
    warning_position = response.body.index("dashboard-plugin-deletion-warnings")
    widget_position = response.body.index("dashboard-widgets")

    assert_operator notice_position, :<, warning_position
    assert_operator warning_position, :<, widget_position
  end

  test "노출 대상 공지가 없으면 공지 영역을 렌더링하지 않는다" do
    sign_in_as @user
    get root_url

    assert_select "#dashboard-notices", count: 0
  end

  test "비인증 랜딩 페이지에는 공지를 표시하지 않는다" do
    create_notice(title: "로그인 전에는 보이지 않는 공지")

    get root_url

    assert_select "#dashboard-notices", count: 0
    assert_no_match "로그인 전에는 보이지 않는 공지", response.body
  end

  private

  def create_notice(title:, body: "공지 내용", published_on: Date.current, expires_on: nil, position: 1)
    Notice.create!(title:, body:, published_on:, expires_on:, position:)
  end
end
