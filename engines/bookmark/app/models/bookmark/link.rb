module Bookmark
  class Link < ApplicationRecord
    self.table_name = "bookmark_links"

    belongs_to :group, class_name: "Bookmark::Group", foreign_key: "bookmark_group_id", counter_cache: :links_count

    validates :title, presence: true, length: { maximum: 100 }
    validates :url, presence: true, format: {
      with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
      message: :invalid_url_format
    }
  end
end
