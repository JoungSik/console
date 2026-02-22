module Settlement
  class Round < ApplicationRecord
    belongs_to :gathering
    has_many :round_members, dependent: :destroy
    has_many :members, -> { order(:id) }, through: :round_members
    has_many :items, dependent: :destroy

    validates :name, presence: true, length: { maximum: 100 }

    after_create :add_all_gathering_members

    def total_amount
      items.sum("amount * quantity")
    end

    private

    def add_all_gathering_members
      gathering.members.each do |member|
        round_members.create!(member: member)
      end
    end
  end
end
