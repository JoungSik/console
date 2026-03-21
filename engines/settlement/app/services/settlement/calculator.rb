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
    end

    def loaded_rounds
      @loaded_rounds ||= gathering.rounds.order(:position, :id)
                                  .includes(:members, items: [ :item_members, :members ])
    end
  end
end
