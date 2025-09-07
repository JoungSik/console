class Collection < ApplicationRecord
  include Hashable

  belongs_to :user
  has_many :links, dependent: :nullify

  validates :title, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }

  before_validation :sanitize_description

  scope :is_public, -> { where(is_public: true) }

  private

  def sanitize_description
    self.description = description&.strip&.presence
  end
end
