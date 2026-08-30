module Todo
  class DataCleaner
    def self.transaction(**options, &block)
      Todo::ApplicationRecord.transaction(**options, &block)
    end

    def self.call(user_id:)
      Todo::List.where(user_id: user_id).destroy_all
    end
  end
end
