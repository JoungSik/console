module Settlement
  class Item < ApplicationRecord
    belongs_to :round
    has_many :item_members, dependent: :destroy
    has_many :members, -> { order(:id) }, through: :item_members

    validates :name, presence: true, length: { maximum: 100 }
    validates :quantity, presence: true, numericality: { greater_than: 0 }
    validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

    # 항목 총액 (수량 x 금액)
    def total
      quantity * amount
    end

    # 이 항목을 부담하는 멤버 목록 반환
    # is_shared이면 라운드 전체 참석자, 태그가 있으면 태그된 멤버
    def responsible_members
      if is_shared || item_members.empty?
        round.members
      else
        members
      end
    end

    # 멤버당 부담 금액 (올림 처리)
    def per_person_amount
      count = responsible_members.count
      return 0 if count.zero?
      (total.to_f / count).ceil
    end
  end
end
