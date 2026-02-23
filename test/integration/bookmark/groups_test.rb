require "test_helper"

class Bookmark::GroupsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
    sign_in_as @user
    @group = Bookmark::Group.create!(title: "테스트 그룹", user_id: @user.id)
  end


  test "그룹 인덱스에 접근할 수 있다" do
    get bookmark.groups_url
    assert_response :success
  end

  test "그룹 상세에 접근할 수 있다" do
    get bookmark.group_url(@group)
    assert_response :success
  end

  test "그룹 생성 폼에 접근할 수 있다" do
    get bookmark.new_group_url
    assert_response :success
  end

  test "그룹 수정 폼에 접근할 수 있다" do
    get bookmark.edit_group_url(@group)
    assert_response :success
  end

  test "그룹을 생성할 수 있다" do
    assert_difference "Bookmark::Group.count", 1 do
      post bookmark.groups_url, params: { group: { title: "새 그룹" } }
    end
    assert_redirected_to bookmark.group_url(Bookmark::Group.last)
  end

  test "공개 그룹을 생성할 수 있다" do
    post bookmark.groups_url, params: { group: { title: "공개 그룹", is_public: true } }
    group = Bookmark::Group.last
    assert group.is_public
  end

  test "링크를 포함하여 그룹을 생성할 수 있다" do
    assert_difference "Bookmark::Group.count", 1 do
      post bookmark.groups_url, params: {
        group: {
          title: "링크 포함 그룹",
          links_attributes: { "0" => { title: "구글", url: "https://google.com" } }
        }
      }
    end
    group = Bookmark::Group.last
    assert_equal 1, group.links.count
  end

  test "제목 없이 생성하면 422를 반환한다" do
    assert_no_difference "Bookmark::Group.count" do
      post bookmark.groups_url, params: { group: { title: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "그룹을 수정할 수 있다" do
    patch bookmark.group_url(@group), params: { group: { title: "수정된 그룹" } }
    assert_redirected_to bookmark.group_url(@group)
    assert_equal "수정된 그룹", @group.reload.title
  end

  test "그룹을 삭제할 수 있다" do
    assert_difference "Bookmark::Group.count", -1 do
      delete bookmark.group_url(@group)
    end
    assert_redirected_to bookmark.groups_url
  end

  test "다른 사용자의 그룹에 접근하면 404를 반환한다" do
    other_group = Bookmark::Group.create!(title: "다른 사용자 그룹", user_id: users(:other_user).id)
    get bookmark.group_url(other_group)
    assert_response :not_found
  end
end
