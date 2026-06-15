module Journal
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    connects_to database: { writing: :journal, reading: :journal }
  end
end
