module Inspiration
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    connects_to database: { writing: :inspiration, reading: :inspiration }
  end
end
