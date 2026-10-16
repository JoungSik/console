module Inspiration
  class Note < ApplicationRecord
    belongs_to :idea, touch: true, counter_cache: true

    validates :body, presence: true

    scope :chronological, -> { order(created_at: :asc, id: :asc) }
  end
end
