module Bookmark
  class Group < ApplicationRecord
    include Bookmark::Hashable

    has_many :links, dependent: :destroy
    accepts_nested_attributes_for :links, reject_if: :all_blank, allow_destroy: true

    validates :title, presence: true, length: { maximum: 100 }

    scope :by_user, ->(user_id) { where(user_id: user_id) }
    scope :published, -> { where(is_public: true) }
  end
end
