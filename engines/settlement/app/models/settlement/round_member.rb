module Settlement
  class RoundMember < ApplicationRecord
    belongs_to :round
    belongs_to :member

    validates :member_id, uniqueness: { scope: :round_id }
  end
end
