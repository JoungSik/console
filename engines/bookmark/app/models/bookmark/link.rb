module Bookmark
  class Link < ApplicationRecord
    belongs_to :group, counter_cache: :links_count

    validates :title, presence: true, length: { maximum: 100 }
    validates :url, presence: true, format: {
      with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
      message: :invalid_url_format
    }
  end
end
