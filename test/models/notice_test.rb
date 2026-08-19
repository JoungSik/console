require "test_helper"

class NoticeTest < ActiveSupport::TestCase
  setup do
    @today = Date.new(2026, 8, 19)
  end

  test "제목과 게시일과 노출 순서는 필수다" do
    notice = Notice.new

    assert_not notice.valid?
    assert_includes notice.errors[:title], "입력해주세요."
    assert_includes notice.errors[:published_on], "입력해주세요."
    assert_includes notice.errors[:position], "입력해주세요."
  end

  test "노출 순서는 정수만 허용한다" do
    notice = Notice.new(title: "공지", published_on: @today, position: 1.5)

    assert_not notice.valid?
    assert_predicate notice.errors[:position], :present?
  end

  test "만료일이 없으면 유효하다" do
    notice = Notice.new(title: "공지", published_on: @today, expires_on: nil, position: 1)

    assert_predicate notice, :valid?
  end

  test "만료일은 게시일보다 빠를 수 없다" do
    notice = Notice.new(title: "공지", published_on: @today, expires_on: @today.yesterday, position: 1)

    assert_not notice.valid?
    assert_includes notice.errors[:expires_on], "은 게시일보다 빠를 수 없습니다."
  end

  test "게시일과 만료일이 같으면 유효하다" do
    notice = Notice.new(title: "공지", published_on: @today, expires_on: @today, position: 1)

    assert_predicate notice, :valid?
  end

  test "visible_on은 게시일 전과 만료일 후 공지를 제외한다" do
    future = create_notice(published_on: @today.tomorrow)
    expired = create_notice(published_on: @today - 2.days, expires_on: @today.yesterday)
    visible = create_notice(published_on: @today.yesterday, expires_on: @today.tomorrow)

    notices = Notice.visible_on(@today)

    assert_includes notices, visible
    assert_not_includes notices, future
    assert_not_includes notices, expired
  end

  test "visible_on은 게시일과 만료일 당일을 포함한다" do
    published_today = create_notice(published_on: @today)
    expires_today = create_notice(published_on: @today.yesterday, expires_on: @today)

    notices = Notice.visible_on(@today)

    assert_includes notices, published_today
    assert_includes notices, expires_today
  end

  test "visible_on은 만료일이 없는 공지를 계속 포함한다" do
    notice = create_notice(published_on: @today.yesterday, expires_on: nil)

    assert_includes Notice.visible_on(@today + 10.years), notice
  end

  test "visible_on은 노출 순서와 id 순서로 안정적으로 정렬한다" do
    second = create_notice(position: 20)
    first_tie = create_notice(position: 10)
    second_tie = create_notice(position: 10)
    first = create_notice(position: 5)

    assert_equal [ first, first_tie, second_tie, second ], Notice.visible_on(@today).to_a
  end

  private

  def create_notice(published_on: @today.yesterday, expires_on: nil, position: 1)
    Notice.create!(title: "공지", published_on:, expires_on:, position:)
  end
end
