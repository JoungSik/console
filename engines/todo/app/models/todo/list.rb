module Todo
  class List < ApplicationRecord
    self.table_name = "todo_lists"

    has_many :items, foreign_key: "todo_list_id", dependent: :destroy
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

    def displayed_items
      items.order(completed: :asc, created_at: :desc).limit(5)
    end
  end
end
