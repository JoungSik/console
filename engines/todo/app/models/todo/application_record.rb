module Todo
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    connects_to database: { writing: :todo, reading: :todo }
  end
end
