module Lottery
  class DataCleaner
    def self.transaction(**options, &block)
      Lottery::ApplicationRecord.transaction(**options, &block)
    end

    def self.call(user_id:)
      Lottery::Account.where(user_id: user_id).destroy_all
    end
  end
end
