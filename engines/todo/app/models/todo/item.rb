module Todo
  class Item < ApplicationRecord
    RECURRENCE_OPTIONS = %w[daily weekly monthly yearly].freeze
    RECURRENCE_LABELS = { "daily" => "매일", "weekly" => "매주", "monthly" => "매월", "yearly" => "매년" }.freeze

    belongs_to :list
    belongs_to :recurrence_parent, class_name: "Todo::Item", optional: true
    has_one :recurrence_child, class_name: "Todo::Item", foreign_key: :recurrence_parent_id, dependent: :destroy

    validates :title, presence: true, length: { maximum: 200 }
    validates :url, format: {
      with: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/,
      message: :invalid_url_format
    }, allow_blank: true
    normalizes :recurrence, with: ->(v) { v.presence }
    validates :recurrence, inclusion: { in: RECURRENCE_OPTIONS }, allow_nil: true
    validate :recurrence_requires_due_date

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

    def recurring?
      recurrence.present?
    end

    def next_due_date
      return nil unless recurring? && due_date.present?

      case recurrence
      when "daily"   then due_date + 1.day
      when "weekly"  then due_date + 1.week
      when "monthly" then due_date + 1.month
      when "yearly"  then due_date + 1.year
      end
    end

    def can_recur_next?
      return false unless recurring? && next_due_date.present?

      recurrence_ends_on.blank? || next_due_date <= recurrence_ends_on
    end

    private

    def recurrence_requires_due_date
      if recurrence.present? && due_date.blank?
        errors.add(:due_date, :blank)
      end
    end
  end
end
