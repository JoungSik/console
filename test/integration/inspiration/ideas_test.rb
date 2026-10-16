require "test_helper"

class Inspiration::IdeasTest < ActionDispatch::IntegrationTest
  NATIVE_HEADERS = { "User-Agent" => "Console Hotwire Native iOS" }.freeze

  setup do
    @user = users(:test_user)
    sign_in_as @user
    @idea = Inspiration::Idea.create!(title: "Vaultwarden 대체 시스템", body: "1Password급 앱", user_id: @user.id)
  end

  test "아이디어 인덱스에 빠른 입력 폼과 목록이 표시된다" do
    get inspiration.root_url

    assert_response :success
    assert_select "title", text: "아이디어 꾸러미"
    assert_select "h1", text: "아이디어 꾸러미"
    assert_select "#idea_composer input[name='idea[title]']"
    assert_select "#idea_composer select[name='idea[status]']", count: 0
    assert_select "#ideas", text: /Vaultwarden 대체 시스템/
  end

  test "상태로 아이디어 목록을 거른다" do
    Inspiration::Idea.create!(title: "검토 중 아이디어", status: :reviewing, user_id: @user.id)

    get inspiration.root_url(status: "reviewing")

    assert_response :success
    assert_select "#ideas", text: /검토 중 아이디어/
    assert_select "#ideas", text: /Vaultwarden 대체 시스템/, count: 0
    assert_select "#idea_filters a[aria-current='page']", text: "검토 중"
  end

  test "알 수 없는 상태 필터는 전체 목록을 보여준다" do
    get inspiration.root_url(status: "unknown")

    assert_response :success
    assert_select "#ideas", text: /Vaultwarden 대체 시스템/
    assert_select "#idea_filters a[aria-current='page']", text: "전체"
  end

  test "상태 필터 링크는 Native 화면이 쌓이지 않도록 현재 방문을 교체한다" do
    get inspiration.root_url

    filter_count = Inspiration::Idea.statuses.size + 1
    assert_select "#idea_filters a", count: filter_count
    assert_select "#idea_filters a[data-turbo-action='replace']", count: filter_count
  end

  test "아이디어 상세에 진행 기록과 기록 폼이 표시된다" do
    @idea.notes.create!(body: "Bitwarden 클라이언트 호환성 확인")

    get inspiration.idea_url(@idea)

    assert_response :success
    assert_select "title", text: @idea.title
    assert_select "#notes", text: /Bitwarden 클라이언트 호환성 확인/
    assert_select "#note_composer textarea[name='note[body]']"
  end

  test "수정 폼에서 상태를 선택할 수 있다" do
    get inspiration.edit_idea_url(@idea)

    assert_response :success
    assert_select "select[name='idea[status]'] option", count: Inspiration::Idea.statuses.size
  end

  test "Native 화면은 웹 제목과 뒤로가기를 표시 영역으로 지정한다" do
    get inspiration.root_url, headers: NATIVE_HEADERS
    assert_select "[data-native-page-title]", text: "아이디어 꾸러미"

    get inspiration.idea_url(@idea), headers: NATIVE_HEADERS
    assert_select "[data-native-page-navigation]", text: "아이디어 꾸러미"

    get inspiration.edit_idea_url(@idea), headers: NATIVE_HEADERS
    assert_select "[data-native-page-title]", text: "아이디어 수정"
  end

  test "아이디어를 생성할 수 있다" do
    assert_difference "Inspiration::Idea.count", 1 do
      post inspiration.ideas_url, params: { idea: { title: "새 아이디어", reference_url: "https://news.example.com/1" } }
    end

    assert_response :see_other
    assert_redirected_to inspiration.root_url
    idea = Inspiration::Idea.last
    assert_equal @user.id, idea.user_id
    assert_equal "https://news.example.com/1", idea.reference_url
    assert idea.spark?
  end

  test "Turbo Stream으로 생성하면 작성 영역과 필터와 목록과 flash를 갱신한다" do
    post inspiration.ideas_url,
      params: { idea: { title: "Stream 아이디어" } },
      headers: turbo_stream_headers

    assert_response :success
    assert_select "turbo-stream[action='update'][target='idea_composer']"
    assert_select "turbo-stream[action='update'][target='idea_filters']"
    assert_select "turbo-stream[action='update'][target='flash']"
    assert_select "turbo-stream[target='ideas']", text: /Stream 아이디어/
  end

  test "필터 화면의 빠른 입력 폼은 현재 필터를 함께 전송한다" do
    get inspiration.root_url(status: "reviewing")

    assert_select "#idea_composer input[type='hidden'][name='status'][value='reviewing']"
  end

  test "필터 화면에서 Turbo Stream으로 생성하면 URL과 같은 필터로 갱신한다" do
    Inspiration::Idea.create!(title: "검토 중 아이디어", status: :reviewing, user_id: @user.id)

    post inspiration.ideas_url,
      params: { status: "reviewing", idea: { title: "필터 중 생성" } },
      headers: turbo_stream_headers

    assert_response :success
    assert_select "turbo-stream[target='idea_filters'] a[aria-current='page']", text: "검토 중"
    assert_select "turbo-stream[target='ideas']", text: /검토 중 아이디어/
    assert_select "turbo-stream[target='ideas']", text: /필터 중 생성/, count: 0
    assert_select "turbo-stream[target='idea_composer'] input[type='hidden'][name='status'][value='reviewing']"
  end

  test "필터 화면에서 HTML로 생성하면 같은 필터로 redirect한다" do
    post inspiration.ideas_url, params: { status: "reviewing", idea: { title: "필터 중 생성" } }

    assert_redirected_to inspiration.root_url(status: "reviewing")
  end

  test "제목 없이 생성하면 422를 반환한다" do
    assert_no_difference "Inspiration::Idea.count" do
      post inspiration.ideas_url, params: { idea: { title: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "Turbo Stream 생성 검증 오류는 작성 영역만 갱신한다" do
    post inspiration.ideas_url,
      params: { idea: { title: "", body: "보존할 내용" } },
      headers: turbo_stream_headers

    assert_response :unprocessable_entity
    assert_select "turbo-stream[action='update'][target='idea_composer']"
    assert_select "turbo-stream[target='ideas']", count: 0
    assert_select "textarea[name='idea[body]']", text: /보존할 내용/
  end

  test "아이디어 상태를 수정할 수 있다" do
    patch inspiration.idea_url(@idea), params: { idea: { status: "in_progress" } }

    assert_response :see_other
    assert_redirected_to inspiration.idea_url(@idea)
    assert @idea.reload.in_progress?
  end

  test "잘못된 링크로 수정하면 422를 반환한다" do
    patch inspiration.idea_url(@idea), params: { idea: { reference_url: "not a url" } }

    assert_response :unprocessable_entity
    assert_nil @idea.reload.reference_url
  end

  test "아이디어를 삭제할 수 있다" do
    assert_difference "Inspiration::Idea.count", -1 do
      delete inspiration.idea_url(@idea)
    end

    assert_response :see_other
    assert_redirected_to inspiration.root_url
  end

  test "인덱스의 Turbo Stream 삭제는 현재 필터 기준으로 목록을 갱신한다" do
    Inspiration::Idea.create!(title: "보류 아이디어", status: :on_hold, user_id: @user.id)
    @idea.update!(status: :on_hold)

    delete inspiration.idea_url(@idea),
      params: { source: "index", status: "on_hold" },
      headers: turbo_stream_headers

    assert_response :success
    assert_select "turbo-stream[action='update'][target='flash']"
    assert_select "turbo-stream[target='ideas']", text: /보류 아이디어/
  end

  test "다른 사용자의 아이디어에 접근하면 404를 반환한다" do
    other_idea = Inspiration::Idea.create!(title: "다른 사용자 아이디어", user_id: users(:other_user).id)

    get inspiration.idea_url(other_idea)
    assert_response :not_found

    patch inspiration.idea_url(other_idea), params: { idea: { title: "변경 시도" } }
    assert_response :not_found

    assert_no_difference "Inspiration::Idea.count" do
      delete inspiration.idea_url(other_idea)
    end
    assert_response :not_found
    assert_equal "다른 사용자 아이디어", other_idea.reload.title
  end
end
