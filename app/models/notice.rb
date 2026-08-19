class Notice < ApplicationRecord
  has_rich_text :body

  validates :title, :published_on, :position, presence: true
  validates :position, numericality: { only_integer: true }
  validate :expires_on_cannot_precede_published_on

  scope :visible_on, ->(date = Date.current) {
    where(published_on: ..date)
      .where(expires_on: nil)
      .or(where(published_on: ..date, expires_on: date..))
      .order(:position, :id)
  }

  private

  def expires_on_cannot_precede_published_on
    return if published_on.blank? || expires_on.blank? || expires_on >= published_on

    errors.add(:expires_on, :before_published_on)
  end
end
