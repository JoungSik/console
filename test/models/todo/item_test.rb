require "test_helper"

class Todo::ItemTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
    @list = Todo::List.create!(title: "테스트 리스트", user_id: @user.id)
    @item = @list.items.build(title: "테스트 할일")
  end

  # === validations ===

  test "유효한 항목이 저장된다" do
    assert @item.valid?
  end

  test "URL이 비어있으면 유효하다" do
    @item.url = ""
    assert @item.valid?
  end

  test "URL이 nil이면 유효하다" do
    @item.url = nil
    assert @item.valid?
  end

  test "http:// URL은 유효하다" do
    @item.url = "http://example.com"
    assert @item.valid?
  end

  test "https:// URL은 유효하다" do
    @item.url = "https://example.com/path?q=1"
    assert @item.valid?
  end

  test "ftp:// URL은 유효하지 않다" do
    @item.url = "ftp://example.com"
    assert_not @item.valid?
    assert_includes @item.errors[:url], I18n.t("activerecord.errors.models.todo/item.attributes.url.invalid_url_format")
  end

  test "프로토콜 없는 URL은 유효하지 않다" do
    @item.url = "example.com"
    assert_not @item.valid?
  end

  test "임의 문자열은 유효하지 않다" do
    @item.url = "not-a-url"
    assert_not @item.valid?
  end

  # === #overdue? ===

  test "마감일이 어제면 overdue?는 true" do
    @item.due_date = Date.current - 1.day
    assert @item.overdue?
  end

  test "마감일이 오늘이면 overdue?는 false" do
    @item.due_date = Date.current
    assert_not @item.overdue?
  end

  test "완료된 항목은 overdue?가 false" do
    @item.due_date = Date.current - 1.day
    @item.completed = true
    assert_not @item.overdue?
  end

  # === #due_today? ===

  test "마감일이 오늘이면 due_today?는 true" do
    @item.due_date = Date.current
    assert @item.due_today?
  end

  test "마감일이 어제면 due_today?는 false" do
    @item.due_date = Date.current - 1.day
    assert_not @item.due_today?
  end

  test "마감일이 내일이면 due_today?는 false" do
    @item.due_date = Date.current + 1.day
    assert_not @item.due_today?
  end

  test "완료된 항목은 due_today?가 false" do
    @item.due_date = Date.current
    @item.completed = true
    assert_not @item.due_today?
  end

  # === #url? ===

  test "URL이 있으면 true를 반환한다" do
    @item.url = "https://example.com"
    assert @item.url?
  end

  test "URL이 nil이면 false를 반환한다" do
    @item.url = nil
    assert_not @item.url?
  end

  test "URL이 빈 문자열이면 false를 반환한다" do
    @item.url = ""
    assert_not @item.url?
  end

  # === 반복(recurrence) validations ===

  test "유효한 반복 옵션은 허용된다" do
    %w[daily weekly monthly yearly].each do |option|
      @item.recurrence = option
      @item.due_date = Date.current
      assert @item.valid?, "#{option}이 유효해야 합니다"
    end
  end

  test "잘못된 반복 옵션은 거부된다" do
    @item.recurrence = "hourly"
    @item.due_date = Date.current
    assert_not @item.valid?
    assert @item.errors[:recurrence].any?
  end

  test "반복이 nil이면 유효하다" do
    @item.recurrence = nil
    assert @item.valid?
  end

  test "반복 설정 시 마감일이 필수이다" do
    @item.recurrence = "daily"
    @item.due_date = nil
    assert_not @item.valid?
    assert @item.errors[:due_date].any?
  end

  test "반복 설정 시 마감일이 있으면 유효하다" do
    @item.recurrence = "daily"
    @item.due_date = Date.current
    assert @item.valid?
  end

  # === #recurring? ===

  test "반복 설정이 있으면 recurring?은 true" do
    @item.recurrence = "weekly"
    assert @item.recurring?
  end

  test "반복 설정이 없으면 recurring?은 false" do
    @item.recurrence = nil
    assert_not @item.recurring?
  end

  # === #next_due_date ===

  test "매일 반복의 다음 마감일은 1일 후" do
    @item.recurrence = "daily"
    @item.due_date = Date.new(2026, 3, 1)
    assert_equal Date.new(2026, 3, 2), @item.next_due_date
  end

  test "매주 반복의 다음 마감일은 7일 후" do
    @item.recurrence = "weekly"
    @item.due_date = Date.new(2026, 3, 1)
    assert_equal Date.new(2026, 3, 8), @item.next_due_date
  end

  test "매월 반복의 다음 마감일은 1개월 후" do
    @item.recurrence = "monthly"
    @item.due_date = Date.new(2026, 1, 31)
    assert_equal Date.new(2026, 2, 28), @item.next_due_date
  end

  test "매년 반복의 다음 마감일은 1년 후" do
    @item.recurrence = "yearly"
    @item.due_date = Date.new(2026, 3, 1)
    assert_equal Date.new(2027, 3, 1), @item.next_due_date
  end

  test "반복이 아니면 next_due_date는 nil" do
    @item.recurrence = nil
    @item.due_date = Date.current
    assert_nil @item.next_due_date
  end

  # === #can_recur_next? ===

  test "종료일이 없으면 다음 반복 가능" do
    @item.recurrence = "daily"
    @item.due_date = Date.current
    @item.recurrence_ends_on = nil
    assert @item.can_recur_next?
  end

  test "다음 마감일이 종료일 이전이면 반복 가능" do
    @item.recurrence = "daily"
    @item.due_date = Date.new(2026, 3, 1)
    @item.recurrence_ends_on = Date.new(2026, 3, 10)
    assert @item.can_recur_next?
  end

  test "다음 마감일이 종료일과 같으면 반복 가능" do
    @item.recurrence = "daily"
    @item.due_date = Date.new(2026, 3, 9)
    @item.recurrence_ends_on = Date.new(2026, 3, 10)
    assert @item.can_recur_next?
  end

  test "다음 마감일이 종료일 이후면 반복 불가" do
    @item.recurrence = "daily"
    @item.due_date = Date.new(2026, 3, 10)
    @item.recurrence_ends_on = Date.new(2026, 3, 10)
    assert_not @item.can_recur_next?
  end

  test "반복이 아니면 can_recur_next?는 false" do
    @item.recurrence = nil
    @item.due_date = Date.current
    assert_not @item.can_recur_next?
  end
end
