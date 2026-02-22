require "application_system_test_case"

class SettlementGatheringsTest < ApplicationSystemTestCase
  setup do
    @user = users(:test_user)
    sign_in_as @user
  end

  teardown do
    Settlement::Gathering.where(user_id: @user.id).destroy_all
  end

  test "모임을 생성할 수 있다" do
    visit settlement.new_gathering_url
    fill_in "gathering[title]", with: "시스템 테스트 모임"
    click_button "모임 만들기"
    assert_text "시스템 테스트 모임"
    assert_text "모임이 생성되었습니다."
  end

  test "모임 인덱스를 조회할 수 있다" do
    Settlement::Gathering.create!(title: "조회용 모임", user_id: @user.id)
    visit settlement.gatherings_url
    assert_text "조회용 모임"
  end

  test "모임을 수정할 수 있다" do
    gathering = Settlement::Gathering.create!(title: "수정 전", user_id: @user.id)
    visit settlement.edit_gathering_url(gathering)
    fill_in "gathering[title]", with: "수정 후"
    click_button "모임 수정"
    assert_text "수정 후"
    assert_text "모임이 수정되었습니다."
  end

  test "모임을 삭제할 수 있다" do
    gathering = Settlement::Gathering.create!(title: "삭제 대상", user_id: @user.id)
    visit settlement.gathering_url(gathering)
    accept_confirm do
      click_button "삭제"
    end
    assert_text "모임이 삭제되었습니다."
  end

  test "빈 상태 메시지가 표시된다" do
    visit settlement.gatherings_url
    assert_text "모임이 없습니다"
  end
end
