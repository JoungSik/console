require "test_helper"

class Todo::ItemTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "테스트", email_address: "test@example.com", password: "password123")
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
end
