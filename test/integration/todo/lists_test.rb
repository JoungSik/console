require "test_helper"

class Todo::ListsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
    sign_in_as @user
    @list = Todo::List.create!(title: "테스트 목록", user_id: @user.id)
  end

  teardown do
    Todo::List.where(user_id: @user.id).destroy_all
  end

  test "목록 인덱스에 접근할 수 있다" do
    get todo.lists_url
    assert_response :success
  end

  test "목록 상세에 접근할 수 있다" do
    get todo.list_url(@list)
    assert_response :success
  end

  test "목록 생성 폼에 접근할 수 있다" do
    get todo.new_list_url
    assert_response :success
  end

  test "목록 수정 폼에 접근할 수 있다" do
    get todo.edit_list_url(@list)
    assert_response :success
  end

  test "제목만으로 목록을 생성할 수 있다" do
    assert_difference "Todo::List.count", 1 do
      post todo.lists_url, params: { list: { title: "새 목록" } }
    end
    assert_redirected_to todo.list_url(Todo::List.last)
  end

  test "항목을 포함하여 목록을 생성할 수 있다" do
    assert_difference "Todo::List.count", 1 do
      post todo.lists_url, params: {
        list: {
          title: "항목 포함 목록",
          items_attributes: { "0" => { title: "할 일 1" } }
        }
      }
    end
    list = Todo::List.last
    assert_equal 1, list.items.count
  end

  test "제목 없이 생성하면 422를 반환한다" do
    assert_no_difference "Todo::List.count" do
      post todo.lists_url, params: { list: { title: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "목록을 수정할 수 있다" do
    patch todo.list_url(@list), params: { list: { title: "수정된 제목" } }
    assert_redirected_to todo.list_url(@list)
    assert_equal "수정된 제목", @list.reload.title
  end

  test "목록을 보관할 수 있다" do
    patch todo.list_url(@list), params: { list: { title: @list.title, archive: "1" } }
    assert_redirected_to todo.list_url(@list)
    assert @list.reload.archived?
  end

  test "목록 보관을 해제할 수 있다" do
    @list.archive!
    patch todo.list_url(@list), params: { list: { title: @list.title, archive: "0" } }
    assert_redirected_to todo.list_url(@list)
    assert_not @list.reload.archived?
  end

  test "목록을 삭제할 수 있다" do
    assert_difference "Todo::List.count", -1 do
      delete todo.list_url(@list)
    end
    assert_redirected_to todo.lists_url
  end

  test "반복 설정을 포함하여 항목을 생성할 수 있다" do
    post todo.lists_url, params: {
      list: {
        title: "반복 목록",
        items_attributes: {
          "0" => { title: "매일 할일", due_date: Date.current, recurrence: "daily" }
        }
      }
    }
    list = Todo::List.last
    item = list.items.first
    assert_equal "daily", item.recurrence
    assert_equal Date.current, item.due_date
  end

  test "다른 사용자의 목록에 접근하면 404를 반환한다" do
    other_list = Todo::List.create!(title: "다른 사용자 목록", user_id: 999999)
    get todo.list_url(other_list)
    assert_response :not_found
    other_list.destroy!
  end
end
