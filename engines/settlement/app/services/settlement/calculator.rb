module Settlement
  class Calculator
    attr_reader :gathering

    ROUNDING_UNIT = 10

    def initialize(gathering)
      @gathering = gathering
    end

    def total_amount
      gathering.total_amount
    end

    def per_member_totals
      compute_results unless @computed
      @per_member_totals
    end

    def rounding_extras
      compute_results unless @computed
      @rounding_extras
    end

    def round_details
      compute_results unless @computed
      @round_details
    end

    # 항목별 나머지 부담자 { item_id => { member:, remainder: } }
    def item_remainder_assignees
      compute_results unless @computed
      @item_remainder_assignees
    end

    def difference
      per_member_totals.values.sum - total_amount
    end

    private

    def compute_results
      totals = Hash.new(0)
      @rounding_extras = Hash.new(0)
      @item_remainder_assignees = {}
      rng = Random.new(gathering.effective_rounding_seed)

      @round_details = loaded_rounds.map do |round|
        member_amounts = Hash.new(0)
        round.items.each do |item|
          responsible = item.responsible_members.to_a
          next if responsible.empty?

          count = responsible.size
          per_person = (item.total / count / ROUNDING_UNIT) * ROUNDING_UNIT
          remainder = item.total - per_person * count

          responsible.each do |member|
            totals[member] += per_person
            member_amounts[member] += per_person
          end

          # 항목별 나머지를 랜덤 1명에게 부과
          if remainder > 0
            lucky = responsible.shuffle(random: rng).first
            totals[lucky] += remainder
            member_amounts[lucky] += remainder
            @rounding_extras[lucky] += remainder
            @item_remainder_assignees[item.id] = { member: lucky, remainder: remainder }
          end
        end

        {
          round: round,
          total: round.total_amount,
          member_amounts: member_amounts
        }
      end

      @per_member_totals = totals.sort_by { |_member, amount| -amount }.to_h
      @computed = true

      equalize_if_possible
    end

    # 총액이 인원수로 깔끔하게 나눠지고, 차이가 반올림에서만 기인하면 균등 금액으로 대체
    def equalize_if_possible
      members = @per_member_totals.keys
      return if members.empty?

      total = total_amount
      count = members.size
      return unless evenly_divisible?(total, count)
      return if has_tagged_items?

      even_amount = total / count
      total_extras = @rounding_extras.values.sum
      return unless @per_member_totals.all? { |_, amt| (amt - even_amount).abs <= total_extras }

      @per_member_totals = members.map { |m| [ m, even_amount ] }.to_h
      @rounding_extras = Hash.new(0)
      @item_remainder_assignees = {}

      equalize_rounds
    end

    # 각 라운드별 독립적으로 균등분배 판단 및 적용
    def equalize_rounds
      @round_details.each do |detail|
        round_members = detail[:member_amounts].keys
        next if round_members.empty?

        round_total = detail[:total]
        round_count = round_members.size
        next unless evenly_divisible?(round_total, round_count)
        next if detail[:round].items.any? { |i| !i.is_shared && i.item_members.any? }

        even_amount = round_total / round_count

        detail[:member_amounts] = round_members.map { |m| [ m, even_amount ] }.to_h
      end
    end

    # 특정 멤버만 참여하는 태그 항목이 존재하는지 확인
    def has_tagged_items?
      loaded_rounds.any? { |r| r.items.any? { |i| !i.is_shared && i.item_members.any? } }
    end

    def evenly_divisible?(amount, count)
      count > 0 && amount % count == 0 && (amount / count) % ROUNDING_UNIT == 0
    end

    def loaded_rounds
      @loaded_rounds ||= gathering.rounds.order(:position, :id)
                                  .includes(:members, items: [ :item_members, :members ])
    end
  end
end
