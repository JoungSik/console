module Journal
  class Post < ApplicationRecord
    MAX_BODY_LENGTH = 280

    validates :user_id, presence: true
    validates :body, presence: true, length: { maximum: MAX_BODY_LENGTH }

    scope :by_user, ->(user_id) { where(user_id: user_id) }
    scope :recent, -> { order(created_at: :desc, id: :desc) }
  end
end
