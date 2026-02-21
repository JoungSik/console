module Todo
  class Item < ApplicationRecord
    belongs_to :list

    validates :title, presence: true, length: { maximum: 200 }

    scope :completed, -> { where(completed: true) }
    scope :incomplete, -> { where(completed: false) }
    scope :overdue, -> { incomplete.where("due_date < ?", Date.current) }
    scope :reminder_pending, -> { overdue.where(reminder_sent: false) }

    def completed?
      completed
    end

    def overdue?
      !completed? && due_date.present? && due_date < Date.current
    end
  end
end
