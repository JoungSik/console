require "test_helper"

class Lottery::TicketOrderTest < ActiveSupport::TestCase
  WEDNESDAY_NOON = Time.zone.parse("2026-10-14 12:00")
  SATURDAY_NIGHT = Time.zone.parse("2026-10-17 21:00")

  setup do
    travel_to WEDNESDAY_NOON
  end

  test "선택한 게임의 번호 개수로 자동·반자동·수동을 정한다" do
    order = build_order("0" => { selected: "1", numbers: "" }, "1" => { selected: "1", numbers: "1, 2" }, "2" => { selected: "1", numbers: "1,2,3,4,5,6" })

    assert order.valid?
    assert_equal %i[auto semi_auto manual], order.tickets.map(&:mode)
    assert_equal [ "A 자동", "B 반자동 1 2", "C 수동 1 2 3 4 5 6" ], order.summary
    assert_equal 3_000, order.total_amount
  end

  test "선택하지 않은 게임은 구매하지 않는다" do
    order = build_order("0" => { selected: "1", numbers: "" }, "1" => { selected: "0", numbers: "1,2,3" })

    assert_equal 1, order.tickets.size
  end

  test "처음 화면에서는 A 게임만 선택한다" do
    order = Lottery::TicketOrder.new

    assert_equal [ true, false, false, false, false ], order.games.map(&:selected)
    assert_equal 1246, order.round
  end

  test "잘못된 번호는 검증 오류로 알린다" do
    order = build_order("0" => { selected: "1", numbers: "1,1,50" })

    assert_not order.valid?
    assert order.errors.of_kind?(:base, :invalid_tickets)
  end

  test "선택한 게임이 없으면 검증 오류다" do
    order = build_order("0" => { selected: "0", numbers: "" })

    assert_not order.valid?
    assert order.errors.of_kind?(:base, :invalid_tickets)
  end

  test "화면을 연 뒤 회차가 바뀌면 구매하지 않는다" do
    order = build_order(round: 1245, "0" => { selected: "1", numbers: "" })

    assert_not order.valid?
    assert order.errors.of_kind?(:base, :round_changed)
  end

  test "판매 마감 시간에는 구매하지 않는다" do
    travel_to SATURDAY_NIGHT

    order = build_order("0" => { selected: "1", numbers: "" })

    assert_not order.valid?
    assert order.errors.of_kind?(:base, :sales_closed)
  end

  private

  def build_order(round: nil, **games)
    Lottery::TicketOrder.new(games: games, round: round)
  end
end
