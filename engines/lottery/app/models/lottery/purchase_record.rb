module Lottery
  class PurchaseRecord < ApplicationRecord
    belongs_to :account

    scope :recent, -> { order(purchased_on: :desc, id: :desc) }
    scope :within_history, -> { where(purchased_on: Synchronizer::HISTORY_DAYS.days.ago.to_date..) }

    def self.attributes_from(entry)
      entry.to_h.slice(:purchased_on, :product_name, :round, :order_no, :barcode, :quantity, :result, :prize_amount, :draw_date)
    end

    def won?
      prize_amount.positive?
    end
  end
end
