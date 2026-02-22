module Settlement
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    connects_to database: { writing: :settlement, reading: :settlement }
  end
end
