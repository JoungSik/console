module Settlement
  class Calculator
    attr_reader :gathering

    REMAINDER_METHOD_LABELS = {
      "ceil" => "올림 (모두 조금씩 더 부담)",
      "first_pays_extra" => "결제자가 나머지 부담"
    }.freeze

    def initialize(gathering)
      @gathering = gathering
    end

    def remainder_method
      gathering.remainder_method
    end

    def remainder_method_label
      REMAINDER_METHOD_LABELS[remainder_method]
    end

    def total_amount
      gathering.total_amount
    end

    def per_member_totals
      totals = Hash.new(0)
      loaded_rounds.each do |round|
        round.items.each do |item|
          distribute_item(item).each do |member, amount|
            totals[member] += amount
          end
        end
      end
      totals.sort_by { |_member, amount| -amount }.to_h
    end

    def round_details
      loaded_rounds.map do |round|
        member_amounts = Hash.new(0)
        round.items.each do |item|
          distribute_item(item).each do |member, amount|
            member_amounts[member] += amount
          end
        end

        {
          round: round,
          total: round.total_amount,
          member_amounts: member_amounts
        }
      end
    end

    def difference
      per_member_totals.values.sum - total_amount
    end

    private

    def loaded_rounds
      @loaded_rounds ||= gathering.rounds.order(:position, :id)
                                  .includes(:members, items: [ :item_members, :members ])
    end

    def distribute_item(item)
      responsible = item.responsible_members.to_a
      return {} if responsible.empty?

      total = item.total
      count = responsible.size

      case remainder_method
      when "ceil"
        distribute_ceil(responsible, total, count)
      when "first_pays_extra"
        distribute_first_pays_extra(responsible, total, count)
      else
        distribute_ceil(responsible, total, count)
      end
    end

    def distribute_ceil(members, total, count)
      per_person = (total.to_f / count).ceil
      members.index_with { per_person }
    end

    def distribute_first_pays_extra(members, total, count)
      per_person = total / count
      remainder = total % count
      members.each_with_index.to_h do |member, i|
        amount = i.zero? ? per_person + remainder : per_person
        [ member, amount ]
      end
    end
  end
end
