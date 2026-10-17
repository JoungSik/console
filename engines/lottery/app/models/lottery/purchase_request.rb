module Lottery
  class PurchaseRequest < ApplicationRecord
    belongs_to :account

    validates :token, presence: true
  end
end
