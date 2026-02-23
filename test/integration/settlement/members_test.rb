require "test_helper"

class Settlement::MembersTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
    sign_in_as @user
    @gathering = Settlement::Gathering.create!(title: "멤버 테스트 모임", user_id: @user.id)
    @gathering.members.create!(name: @user.name)
  end


  test "참석자를 추가할 수 있다" do
    assert_difference "@gathering.members.count", 1 do
      post settlement.gathering_members_url(@gathering), params: { member: { name: "새 참석자" } }
    end
    assert_redirected_to settlement.gathering_url(@gathering)
  end

  test "중복 이름으로 참석자를 추가하면 실패한다" do
    assert_no_difference "@gathering.members.count" do
      post settlement.gathering_members_url(@gathering), params: { member: { name: @user.name } }
    end
    assert_redirected_to settlement.gathering_url(@gathering)
  end

  test "참석자를 삭제할 수 있다" do
    member = @gathering.members.create!(name: "삭제 대상")
    assert_difference "@gathering.members.count", -1 do
      delete settlement.gathering_member_url(@gathering, member)
    end
    assert_redirected_to settlement.gathering_url(@gathering)
  end
end
