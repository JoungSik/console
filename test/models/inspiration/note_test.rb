require "test_helper"

class Inspiration::NoteTest < ActiveSupport::TestCase
  setup do
    @idea = Inspiration::Idea.create!(title: "아이디어", user_id: users(:test_user).id)
  end

  test "본문이 없으면 유효하지 않다" do
    note = @idea.notes.build(body: "")

    assert_not note.valid?
    assert note.errors.added?(:body, :blank)
  end

  test "진행 기록을 추가하면 아이디어 갱신 시각과 기록 수가 바뀐다" do
    @idea.update_columns(updated_at: 1.day.ago)

    @idea.notes.create!(body: "검토 시작")
    @idea.reload

    assert_in_delta Time.current, @idea.updated_at, 5.seconds
    assert_equal 1, @idea.notes_count
  end
end
