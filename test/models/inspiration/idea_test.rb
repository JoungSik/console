require "test_helper"

class Inspiration::IdeaTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
  end

  test "제목만으로 생성되고 기본 상태는 떠오름이다" do
    idea = Inspiration::Idea.create!(title: "Vaultwarden 대체 시스템", user_id: @user.id)

    assert idea.spark?
    assert_equal "떠오름", idea.status_label
  end

  test "제목이 없으면 유효하지 않다" do
    idea = Inspiration::Idea.new(title: "", user_id: @user.id)

    assert_not idea.valid?
    assert idea.errors.added?(:title, :blank)
  end

  test "제목이 최대 길이를 넘으면 유효하지 않다" do
    idea = Inspiration::Idea.new(title: "가" * (Inspiration::Idea::MAX_TITLE_LENGTH + 1), user_id: @user.id)

    assert_not idea.valid?
  end

  test "참고 링크는 http 또는 https URL이어야 한다" do
    idea = Inspiration::Idea.new(title: "아이디어", user_id: @user.id, reference_url: "ftp://example.com")

    assert_not idea.valid?
    assert idea.errors.of_kind?(:reference_url, :invalid)
  end

  test "http 참고 링크는 URI로 반환한다" do
    idea = Inspiration::Idea.new(title: "아이디어", reference_url: "https://news.example.com/articles/1")

    assert_equal "news.example.com", idea.reference_uri.host
  end

  test "http가 아닌 참고 링크는 URI로 반환하지 않는다" do
    idea = Inspiration::Idea.new(title: "아이디어", reference_url: "javascript:alert(1)")

    assert_nil idea.reference_uri
  end

  test "알 수 없는 상태는 유효하지 않다" do
    idea = Inspiration::Idea.new(title: "아이디어", user_id: @user.id, status: "unknown")

    assert_not idea.valid?
  end

  test "모든 상태에 라벨이 있다" do
    assert_equal Inspiration::Idea.statuses.keys, Inspiration::Idea::STATUS_LABELS.keys
  end

  test "삭제하면 진행 기록도 삭제된다" do
    idea = Inspiration::Idea.create!(title: "아이디어", user_id: @user.id)
    idea.notes.create!(body: "검토 시작")

    assert_difference -> { Inspiration::Note.count }, -1 do
      idea.destroy!
    end
  end
end
