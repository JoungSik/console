module Inspiration
  class DataCleaner
    def self.transaction(**options, &block)
      Inspiration::ApplicationRecord.transaction(**options, &block)
    end

    def self.call(user_id:)
      Inspiration::Idea.where(user_id: user_id).destroy_all
    end
  end
end
