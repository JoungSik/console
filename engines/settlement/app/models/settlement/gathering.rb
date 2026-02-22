module Settlement
  class Gathering < ApplicationRecord
    has_many :members, dependent: :destroy
    has_many :rounds, dependent: :destroy

    REMAINDER_METHODS = %w[ceil first_pays_extra].freeze

    validates :title, presence: true, length: { maximum: 100 }
    validates :user_id, presence: true
    validates :remainder_method, inclusion: { in: REMAINDER_METHODS }

    scope :by_user, ->(user_id) { where(user_id: user_id) }

    def total_amount
      rounds.joins(:items).sum("items.amount * items.quantity")
    end
  end
end
