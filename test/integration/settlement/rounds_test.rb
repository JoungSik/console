require "test_helper"

class Settlement::RoundsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
    sign_in_as @user
    @gathering = Settlement::Gathering.create!(title: "라운드 테스트 모임", user_id: @user.id)
    @member = @gathering.members.create!(name: @user.name)
    @round = @gathering.rounds.create!(name: "1차")
  end


  test "라운드 상세에 접근할 수 있다" do
    get settlement.gathering_round_url(@gathering, @round)
    assert_response :success
  end

  test "라운드 생성 폼에 접근할 수 있다" do
    get settlement.new_gathering_round_url(@gathering)
    assert_response :success
  end

  test "라운드 수정 폼에 접근할 수 있다" do
    get settlement.edit_gathering_round_url(@gathering, @round)
    assert_response :success
  end

  test "라운드를 생성할 수 있다" do
    assert_difference "@gathering.rounds.count", 1 do
      post settlement.gathering_rounds_url(@gathering), params: { round: { name: "2차" } }
    end
    round = Settlement::Round.last
    assert_redirected_to settlement.gathering_round_url(@gathering, round)
    # 생성 시 모임의 모든 멤버가 자동으로 추가된다
    assert_equal @gathering.members.count, round.members.count
  end

  test "이름 없이 생성하면 422를 반환한다" do
    assert_no_difference "@gathering.rounds.count" do
      post settlement.gathering_rounds_url(@gathering), params: { round: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "라운드를 수정할 수 있다" do
    patch settlement.gathering_round_url(@gathering, @round), params: { round: { name: "수정된 라운드" } }
    assert_redirected_to settlement.gathering_round_url(@gathering, @round)
    assert_equal "수정된 라운드", @round.reload.name
  end

  test "라운드를 삭제할 수 있다" do
    assert_difference "@gathering.rounds.count", -1 do
      delete settlement.gathering_round_url(@gathering, @round)
    end
    assert_redirected_to settlement.gathering_url(@gathering)
  end

  test "라운드 참석자를 업데이트할 수 있다" do
    member2 = @gathering.members.create!(name: "참석자2")
    # after_create 콜백으로 이미 추가됨, member2는 아직 라운드에 없을 수 있음
    @round.reload

    patch settlement.update_members_gathering_round_url(@gathering, @round), params: {
      member_ids: [ @member.id ]
    }
    assert_redirected_to settlement.gathering_round_url(@gathering, @round)
    assert_equal [ @member.id ], @round.reload.member_ids
  end
end
