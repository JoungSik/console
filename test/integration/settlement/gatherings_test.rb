require "test_helper"

class Settlement::GatheringsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:test_user)
    sign_in_as @user
    @gathering = Settlement::Gathering.create!(title: "테스트 모임", user_id: @user.id, gathering_date: Date.current)
    @gathering.members.create!(name: @user.name)
  end

  teardown do
    Settlement::Gathering.where(user_id: @user.id).destroy_all
  end

  test "모임 인덱스에 접근할 수 있다" do
    get settlement.gatherings_url
    assert_response :success
  end

  test "모임 상세에 접근할 수 있다" do
    get settlement.gathering_url(@gathering)
    assert_response :success
  end

  test "모임 생성 폼에 접근할 수 있다" do
    get settlement.new_gathering_url
    assert_response :success
  end

  test "모임 수정 폼에 접근할 수 있다" do
    get settlement.edit_gathering_url(@gathering)
    assert_response :success
  end

  test "모임을 생성할 수 있다" do
    assert_difference "Settlement::Gathering.count", 1 do
      post settlement.gatherings_url, params: {
        gathering: { title: "새 모임", gathering_date: Date.current }
      }
    end
    gathering = Settlement::Gathering.last
    assert_redirected_to settlement.gathering_url(gathering)
    # 생성 시 현재 사용자가 자동으로 멤버에 추가된다
    assert_equal 1, gathering.members.count
  end

  test "메모와 나머지 방식을 포함하여 모임을 생성할 수 있다" do
    post settlement.gatherings_url, params: {
      gathering: { title: "상세 모임", gathering_date: Date.current, memo: "테스트 메모", remainder_method: "first_pays_extra" }
    }
    gathering = Settlement::Gathering.last
    assert_equal "테스트 메모", gathering.memo
    assert_equal "first_pays_extra", gathering.remainder_method
  end

  test "제목 없이 생성하면 422를 반환한다" do
    assert_no_difference "Settlement::Gathering.count" do
      post settlement.gatherings_url, params: { gathering: { title: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "모임을 수정할 수 있다" do
    patch settlement.gathering_url(@gathering), params: { gathering: { title: "수정된 모임" } }
    assert_redirected_to settlement.gathering_url(@gathering)
    assert_equal "수정된 모임", @gathering.reload.title
  end

  test "모임을 삭제할 수 있다" do
    assert_difference "Settlement::Gathering.count", -1 do
      delete settlement.gathering_url(@gathering)
    end
    assert_redirected_to settlement.gatherings_url
  end

  test "정산 결과 페이지에 접근할 수 있다" do
    get settlement.result_gathering_url(@gathering)
    assert_response :success
  end

  test "다른 사용자의 모임에 접근하면 404를 반환한다" do
    other = Settlement::Gathering.create!(title: "다른 사용자 모임", user_id: 999999)
    get settlement.gathering_url(other)
    assert_response :not_found
    other.destroy!
  end
end
