class Collection < ApplicationRecord
  include Hashable

  belongs_to :user
  has_many :links, dependent: :destroy
  accepts_nested_attributes_for :links, reject_if: :all_blank, allow_destroy: true

  validates :title, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }

  before_validation :sanitize_description

  scope :is_public, -> { where(is_public: true) }

  private

  def sanitize_description
    self.description = description&.strip&.presence
  end
end
