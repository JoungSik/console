class TodoList < ApplicationRecord
  belongs_to :user
  has_many :todos, dependent: :destroy
  accepts_nested_attributes_for :todos, allow_destroy: true, reject_if: :all_blank

  has_many :not_completed_todos, -> { not_completed }, class_name: "Todo"

  validates :title, presence: true, length: { maximum: 100 }
end
