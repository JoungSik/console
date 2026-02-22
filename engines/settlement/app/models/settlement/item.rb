module Settlement
  class Item < ApplicationRecord
    belongs_to :round
    has_many :item_members, dependent: :destroy
    has_many :members, -> { order(:id) }, through: :item_members

    validates :name, presence: true, length: { maximum: 100 }
    validates :quantity, presence: true, numericality: { greater_than: 0 }
    validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

    def total
      quantity * amount
    end

    def responsible_members
      if is_shared || item_members.empty?
        round.members
      else
        members
      end
    end
  end
end
