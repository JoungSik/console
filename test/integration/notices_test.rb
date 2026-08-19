require "test_helper"

class NoticesTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
    @notice = Notice.create!(
      title: "중요 공지",
      body: <<~HTML,
        <p><strong>공지 내용</strong></p>
        <ul><li><a href="https://example.com">자세히 보기</a></li></ul>
        <script>window.unsafeNotice = true</script>
      HTML
      published_on: Date.current,
      position: 1
    )
  end

  test "인증 사용자는 노출 중인 공지 상세를 조회할 수 있다" do
    sign_in_as @user

    get notice_url(@notice)

    assert_response :success
    assert_select "title", @notice.title
    assert_select "h1[data-native-page-title]", @notice.title
    assert_select ".lexxy-content strong", "공지 내용"
    assert_select ".lexxy-content ul li a[href='https://example.com']", "자세히 보기"
    assert_select "article script", count: 0
  end

  test "비인증 사용자는 공지 상세에 접근할 수 없다" do
    get notice_url(@notice)

    assert_redirected_to new_session_path
  end

  test "Native 비인증 요청은 공지 상세 URL을 보존하고 unauthorized를 반환한다" do
    get notice_url(@notice), headers: { "User-Agent" => "Console Hotwire Native iOS" }

    assert_response :unauthorized
    post session_url, params: { email_address: @user.email_address, password: "password123" }
    assert_redirected_to notice_url(@notice)
  end

  test "게시 전 공지에는 직접 접근할 수 없다" do
    notice = Notice.create!(title: "게시 전", published_on: Date.current.tomorrow, position: 1)
    sign_in_as @user

    get notice_url(notice)

    assert_response :not_found
  end

  test "만료된 공지에는 직접 접근할 수 없다" do
    notice = Notice.create!(
      title: "만료됨",
      published_on: Date.current - 2.days,
      expires_on: Date.current.yesterday,
      position: 1
    )
    sign_in_as @user

    get notice_url(notice)

    assert_response :not_found
  end
end
