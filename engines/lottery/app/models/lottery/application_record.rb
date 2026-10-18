module Lottery
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    connects_to database: { writing: :lottery, reading: :lottery }
  end
end
