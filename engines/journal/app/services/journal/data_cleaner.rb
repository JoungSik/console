module Journal
  class DataCleaner
    def self.call(user_id:)
      Journal::Post.where(user_id: user_id).destroy_all
    end
  end
end
