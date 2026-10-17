require "test_helper"

class Inspiration::NotesTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
    sign_in_as @user
    @idea = Inspiration::Idea.create!(title: "Vaultwarden 대체 시스템", user_id: @user.id)
  end

  test "진행 기록을 추가할 수 있다" do
    assert_difference "@idea.notes.count", 1 do
      post inspiration.idea_notes_url(@idea), params: { note: { body: "자체 서버 요구사항 정리" } }
    end

    assert_response :see_other
    assert_redirected_to inspiration.idea_url(@idea)
  end

  test "Turbo Stream으로 추가하면 타임라인과 아이디어 카드와 flash를 갱신한다" do
    post inspiration.idea_notes_url(@idea),
      params: { note: { body: "Stream 기록" } },
      headers: turbo_stream_headers

    assert_response :success
    assert_select "turbo-stream[action='update'][target='note_composer']"
    assert_select "turbo-stream[target='notes']", text: /Stream 기록/
    assert_select "turbo-stream[action='replace'][target='#{ActionView::RecordIdentifier.dom_id(@idea)}']", text: /진행 기록 1/
    assert_select "turbo-stream[action='update'][target='flash']"
  end

  test "빈 진행 기록은 422를 반환한다" do
    assert_no_difference "Inspiration::Note.count" do
      post inspiration.idea_notes_url(@idea), params: { note: { body: "" } }
    end

    assert_response :unprocessable_entity
    assert_select "#note_composer textarea[name='note[body]']"
  end

  test "Turbo Stream 추가 검증 오류는 기록 폼만 갱신한다" do
    post inspiration.idea_notes_url(@idea),
      params: { note: { body: "" } },
      headers: turbo_stream_headers

    assert_response :unprocessable_entity
    assert_select "turbo-stream[action='update'][target='note_composer']"
    assert_select "turbo-stream[target='notes']", count: 0
  end

  test "진행 기록을 삭제할 수 있다" do
    note = @idea.notes.create!(body: "삭제할 기록")

    assert_difference "Inspiration::Note.count", -1 do
      delete inspiration.idea_note_url(@idea, note), headers: turbo_stream_headers
    end

    assert_response :success
    assert_select "turbo-stream[target='notes']", text: /아직 진행 기록이 없습니다/
  end

  test "다른 사용자의 아이디어에는 진행 기록을 추가할 수 없다" do
    other_idea = Inspiration::Idea.create!(title: "다른 사용자 아이디어", user_id: users(:other_user).id)

    assert_no_difference "Inspiration::Note.count" do
      post inspiration.idea_notes_url(other_idea), params: { note: { body: "침입" } }
    end

    assert_response :not_found
  end

  test "다른 아이디어의 진행 기록은 삭제할 수 없다" do
    other_idea = Inspiration::Idea.create!(title: "다른 아이디어", user_id: users(:other_user).id)
    other_note = other_idea.notes.create!(body: "다른 기록")

    assert_no_difference "Inspiration::Note.count" do
      delete inspiration.idea_note_url(@idea, other_note)
    end

    assert_response :not_found
  end
end
