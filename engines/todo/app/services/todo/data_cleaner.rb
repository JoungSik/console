# 사용자의 모든 할 일 데이터 삭제
module Todo
  class DataCleaner
    def self.call(user_id:)
      Todo::List.where(user_id: user_id).destroy_all
    end
  end
end
