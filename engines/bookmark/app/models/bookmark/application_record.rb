module Bookmark
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    connects_to database: { writing: :bookmark, reading: :bookmark }
  end
end
