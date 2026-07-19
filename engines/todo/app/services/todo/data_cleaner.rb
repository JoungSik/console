module Todo
  class DataCleaner
    def self.call(user_id:)
      Todo::List.where(user_id: user_id).destroy_all
    end
  end
end
