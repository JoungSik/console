require "application_system_test_case"

class BookmarkGroupsTest < ApplicationSystemTestCase
  setup do
    @user = users(:test_user)
    sign_in_as @user
  end

  teardown do
    Bookmark::Group.where(user_id: @user.id).destroy_all
  end

  test "북마크 그룹을 생성할 수 있다" do
    visit bookmark.new_group_url
    fill_in "group[title]", with: "시스템 테스트 그룹"
    click_button "북마크 그룹 만들기"
    assert_text "시스템 테스트 그룹"
    assert_text "북마크 그룹이 생성되었습니다."
  end

  test "북마크 그룹 인덱스를 조회할 수 있다" do
    Bookmark::Group.create!(title: "조회용 그룹", user_id: @user.id)
    visit bookmark.groups_url
    assert_text "조회용 그룹"
  end

  test "북마크 그룹을 수정할 수 있다" do
    group = Bookmark::Group.create!(title: "수정 전", user_id: @user.id)
    visit bookmark.edit_group_url(group)
    fill_in "group[title]", with: "수정 후"
    click_button "북마크 그룹 수정"
    assert_text "수정 후"
    assert_text "북마크 그룹이 수정되었습니다."
  end

  test "북마크 그룹을 삭제할 수 있다" do
    group = Bookmark::Group.create!(title: "삭제 대상", user_id: @user.id)
    visit bookmark.group_url(group)
    accept_confirm do
      click_button "삭제"
    end
    assert_text "북마크 그룹이 삭제되었습니다."
  end

  test "빈 상태 메시지가 표시된다" do
    visit bookmark.groups_url
    assert_text "북마크 그룹이 없습니다"
  end
end
