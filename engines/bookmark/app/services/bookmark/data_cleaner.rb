# 사용자의 모든 북마크 데이터 삭제
module Bookmark
  class DataCleaner
    def self.call(user_id:)
      Bookmark::Group.where(user_id: user_id).destroy_all
    end
  end
end
