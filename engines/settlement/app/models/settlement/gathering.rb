module Settlement
  class Gathering < ApplicationRecord
    has_many :members, dependent: :destroy
    has_many :rounds, dependent: :destroy

    validates :title, presence: true, length: { maximum: 100 }
    validates :user_id, presence: true

    scope :by_user, ->(user_id) { where(user_id: user_id) }

    # rounding_seed가 없으면 id를 기본값으로 사용
    def effective_rounding_seed
      rounding_seed || id
    end

    def shuffle_rounding_seed!
      update!(rounding_seed: SecureRandom.random_number(1_000_000))
    end

    def total_amount
      rounds.joins(:items).sum("items.amount * items.quantity")
    end
  end
end
