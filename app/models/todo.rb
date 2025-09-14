class Todo < ApplicationRecord
  belongs_to :todo_list

  validates :title, presence: true, length: { maximum: 200 }

  scope :not_completed, -> { where(completed: false) }
end
