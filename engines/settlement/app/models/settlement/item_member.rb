module Settlement
  class ItemMember < ApplicationRecord
    belongs_to :item
    belongs_to :member

    validates :member_id, uniqueness: { scope: :item_id }
  end
end
