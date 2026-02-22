module Settlement
  # 모임의 정산 결과를 계산하는 서비스 객체
  #
  # 나머지 처리 방식:
  #   - ceil: 올림 (모든 사람이 올림 금액 지불, 합계 > 실제 총액)
  #   - first_pays_extra: 내림 후 나머지를 결제자(첫 번째 참석자)가 부담
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

    # 전체 총액
    def total_amount
      gathering.total_amount
    end

    # 멤버별 부담 총액 { member => amount }
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

    # 라운드별 상세 내역
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

    # 실제 총액과 정산 합계의 차이
    def difference
      per_member_totals.values.sum - total_amount
    end

    private

    def loaded_rounds
      @loaded_rounds ||= gathering.rounds.order(:position, :id)
                                  .includes(:members, items: [ :item_members, :members ])
    end

    # 항목 금액을 참석자에게 분배 { member => amount }
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

    # 올림: 모든 사람이 ceil(total/N) 지불
    def distribute_ceil(members, total, count)
      per_person = (total.to_f / count).ceil
      members.index_with { per_person }
    end

    # 결제자(첫 번째 참석자)가 나머지 부담: floor + 나머지를 결제자에게
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
