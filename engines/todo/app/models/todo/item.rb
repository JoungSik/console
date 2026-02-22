module Todo
  class Item < ApplicationRecord
    belongs_to :list

    validates :title, presence: true, length: { maximum: 200 }
    validates :url, format: {
      with: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/,
      message: :invalid_url_format
    }, allow_blank: true

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

    def url?
      url.present?
    end
  end
end
