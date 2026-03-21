require "test_helper"

class Settlement::CalculatorTest < ActiveSupport::TestCase
  setup do
    @user = users(:test_user)
    @gathering = Settlement::Gathering.create!(title: "팀 회식", user_id: @user.id)
    @member1 = @gathering.members.create!(name: "홍길동")
    @member2 = @gathering.members.create!(name: "김철수")
    @member3 = @gathering.members.create!(name: "이영희")
  end

  test "빈 모임의 총액은 0" do
    calculator = Settlement::Calculator.new(@gathering)
    assert_equal 0, calculator.total_amount
    assert_empty calculator.per_member_totals
  end

  test "단일 라운드 균등 분배" do
    round = @gathering.rounds.create!(name: "1차")
    round.items.create!(name: "삼겹살", quantity: 1, amount: 30000)

    calculator = Settlement::Calculator.new(@gathering)
    totals = calculator.per_member_totals
    assert_equal 10000, totals[@member1]
    assert_equal 10000, totals[@member2]
    assert_equal 10000, totals[@member3]
    assert_equal 0, calculator.difference
  end

  test "나머지가 발생하면 항목별 랜덤 1명에게 부과하고 합계가 일치" do
    round = @gathering.rounds.create!(name: "1차")
    round.items.create!(name: "피자", quantity: 1, amount: 10000)

    calculator = Settlement::Calculator.new(@gathering)
    totals = calculator.per_member_totals

    assert_equal 10000, totals.values.sum
    assert_equal 0, calculator.difference

    extras = calculator.rounding_extras
    assert_equal 10, extras.values.sum
    assert_equal 1, extras.values.count { |v| v > 0 }
  end

  test "나머지 20원도 항목별 1명이 전액 부담" do
    round = @gathering.rounds.create!(name: "1차")
    round.items.create!(name: "치킨", quantity: 1, amount: 20000)

    calculator = Settlement::Calculator.new(@gathering)
    totals = calculator.per_member_totals

    assert_equal 20000, totals.values.sum
    assert_equal 0, calculator.difference

    extras = calculator.rounding_extras
    assert_equal 20, extras.values.sum
    assert_equal 20, extras.values.max
  end

  test "라운드 상세 pill 합계가 라운드 총액과 일치" do
    round = @gathering.rounds.create!(name: "1차")
    round.items.create!(name: "피자", quantity: 1, amount: 10000, is_shared: true)

    calculator = Settlement::Calculator.new(@gathering)
    detail = calculator.round_details.first

    assert_equal detail[:total], detail[:member_amounts].values.sum
  end

  test "다시 뽑기로 나머지 부담자가 변경된다" do
    round = @gathering.rounds.create!(name: "1차")
    round.items.create!(name: "피자", quantity: 1, amount: 10000)

    calc1 = Settlement::Calculator.new(@gathering)
    extras1 = calc1.rounding_extras.dup

    changed = false
    10.times do
      @gathering.shuffle_rounding_seed!
      calc2 = Settlement::Calculator.new(@gathering.reload)
      if calc2.rounding_extras != extras1
        changed = true
        break
      end
    end

    assert changed, "시드 변경 시 나머지 부담자가 달라져야 합니다"
  end

  test "특정 멤버만 태그된 항목" do
    round = @gathering.rounds.create!(name: "1차")
    item = round.items.create!(name: "소주", quantity: 2, amount: 5000)
    item.item_members.create!(member: @member1)
    item.item_members.create!(member: @member2)

    calculator = Settlement::Calculator.new(@gathering)
    totals = calculator.per_member_totals

    assert_equal 5000, totals[@member1]
    assert_equal 5000, totals[@member2]
    assert_equal 0, totals[@member3] || 0
  end

  test "공통 비용은 전원 분배" do
    round = @gathering.rounds.create!(name: "1차")
    round.items.create!(name: "봉사료", quantity: 1, amount: 9000, is_shared: true)
    item = round.items.create!(name: "소주", quantity: 1, amount: 10000)
    item.item_members.create!(member: @member1)
    item.item_members.create!(member: @member2)

    calculator = Settlement::Calculator.new(@gathering)
    totals = calculator.per_member_totals

    assert_equal 19000, totals.values.sum
    assert_equal 0, calculator.difference
  end

  test "여러 라운드 합산" do
    round1 = @gathering.rounds.create!(name: "1차")
    round1.items.create!(name: "삼겹살", quantity: 1, amount: 30000)

    round2 = @gathering.rounds.create!(name: "2차")
    round2.items.create!(name: "맥주", quantity: 1, amount: 15000)

    calculator = Settlement::Calculator.new(@gathering)
    assert_equal 45000, calculator.total_amount

    totals = calculator.per_member_totals
    assert_equal 15000, totals[@member1]
    assert_equal 15000, totals[@member2]
    assert_equal 15000, totals[@member3]
  end

  test "round_details 라운드별 상세" do
    round = @gathering.rounds.create!(name: "1차")
    round.items.create!(name: "삼겹살", quantity: 1, amount: 30000)

    calculator = Settlement::Calculator.new(@gathering)
    details = calculator.round_details

    assert_equal 1, details.size
    assert_equal round, details.first[:round]
    assert_equal 30000, details.first[:total]
    assert_equal 10000, details.first[:member_amounts][@member1]
  end

  test "나머지 없으면 rounding_extras 모두 0" do
    round = @gathering.rounds.create!(name: "1차")
    round.items.create!(name: "삼겹살", quantity: 1, amount: 30000)

    calculator = Settlement::Calculator.new(@gathering)
    extras = calculator.rounding_extras

    assert_equal 0, extras.values.sum
  end
end
