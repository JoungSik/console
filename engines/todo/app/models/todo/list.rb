module Todo
  class List < ApplicationRecord
    has_many :items, dependent: :destroy
    accepts_nested_attributes_for :items, reject_if: :all_blank, allow_destroy: true

    validates :title, presence: true, length: { maximum: 100 }

    scope :active, -> { where(archived_at: nil) }
    scope :archived, -> { where.not(archived_at: nil) }
    scope :by_user, ->(user_id) { where(user_id: user_id) }

    def archived?
      archived_at.present?
    end

    def archive!
      update!(archived_at: Time.current)
    end

    def unarchive!
      update!(archived_at: nil)
    end

    def sorted_items
      items.order(completed: :asc, due_date: :asc, created_at: :desc)
    end

    def displayed_items
      sorted_items.limit(5)
    end
  end
end
