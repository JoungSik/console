module Settlement
  class Member < ApplicationRecord
    belongs_to :gathering
    has_many :round_members, dependent: :destroy
    has_many :rounds, through: :round_members
    has_many :item_members, dependent: :destroy
    has_many :items, through: :item_members

    validates :name, presence: true, length: { maximum: 50 }
    validates :name, uniqueness: { scope: :gathering_id }
  end
end
