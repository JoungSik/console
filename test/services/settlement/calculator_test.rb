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
    assert_equal 30000, calculator.total_amount

    totals = calculator.per_member_totals
    # 30000 / 3 = 10000
    assert_equal 10000, totals[@member1]
    assert_equal 10000, totals[@member2]
    assert_equal 10000, totals[@member3]
  end

  test "올림 처리 확인 (ceil)" do
    round = @gathering.rounds.create!(name: "1차")
    round.items.create!(name: "피자", quantity: 1, amount: 10000)

    calculator = Settlement::Calculator.new(@gathering)
    totals = calculator.per_member_totals

    # 10000 / 3 = 3333.33... → ceil → 3334
    assert_equal 3334, totals[@member1]
    assert_equal 3334, totals[@member2]
    assert_equal 3334, totals[@member3]

    # 올림이므로 합계 > 총액
    assert_equal 2, calculator.difference # 10002 - 10000
  end

  test "결제자가 나머지 부담 (first_pays_extra)" do
    @gathering.update!(remainder_method: "first_pays_extra")
    round = @gathering.rounds.create!(name: "1차")
    round.items.create!(name: "피자", quantity: 1, amount: 10000)

    calculator = Settlement::Calculator.new(@gathering)
    totals = calculator.per_member_totals

    # 10000 / 3 = 3333 나머지 1 → 결제자(첫 번째)가 +1
    assert_equal 3334, totals[@member1]  # 결제자
    assert_equal 3333, totals[@member2]
    assert_equal 3333, totals[@member3]

    # 합계 = 총액 (정확히 나눠짐)
    assert_equal 0, calculator.difference
  end

  test "특정 멤버만 태그된 항목" do
    round = @gathering.rounds.create!(name: "1차")
    item = round.items.create!(name: "소주", quantity: 2, amount: 5000)
    # 홍길동, 김철수만 태그
    item.item_members.create!(member: @member1)
    item.item_members.create!(member: @member2)

    calculator = Settlement::Calculator.new(@gathering)
    totals = calculator.per_member_totals

    # 10000 / 2 = 5000
    assert_equal 5000, totals[@member1]
    assert_equal 5000, totals[@member2]
    assert_equal 0, totals[@member3] || 0
  end

  test "공통 비용은 전원 분배" do
    round = @gathering.rounds.create!(name: "1차")
    # is_shared=true 항목
    round.items.create!(name: "봉사료", quantity: 1, amount: 9000, is_shared: true)
    # 태그된 항목
    item = round.items.create!(name: "소주", quantity: 1, amount: 10000)
    item.item_members.create!(member: @member1)
    item.item_members.create!(member: @member2)

    calculator = Settlement::Calculator.new(@gathering)
    totals = calculator.per_member_totals

    # 봉사료: 9000/3 = 3000 (전원)
    # 소주: 10000/2 = 5000 (홍길동, 김철수만)
    assert_equal 8000, totals[@member1]  # 3000 + 5000
    assert_equal 8000, totals[@member2]  # 3000 + 5000
    assert_equal 3000, totals[@member3]  # 3000
  end

  test "여러 라운드 합산" do
    round1 = @gathering.rounds.create!(name: "1차")
    round1.items.create!(name: "삼겹살", quantity: 1, amount: 30000)

    round2 = @gathering.rounds.create!(name: "2차")
    round2.items.create!(name: "맥주", quantity: 1, amount: 15000)

    calculator = Settlement::Calculator.new(@gathering)
    assert_equal 45000, calculator.total_amount

    totals = calculator.per_member_totals
    # 1차: 30000/3=10000, 2차: 15000/3=5000 → 15000
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

  test "remainder_method_label 반환" do
    calculator = Settlement::Calculator.new(@gathering)
    assert_equal "올림 (모두 조금씩 더 부담)", calculator.remainder_method_label

    @gathering.update!(remainder_method: "first_pays_extra")
    calculator = Settlement::Calculator.new(@gathering)
    assert_equal "결제자가 나머지 부담", calculator.remainder_method_label
  end
end
