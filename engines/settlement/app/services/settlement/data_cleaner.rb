# 사용자의 모든 정산 데이터 삭제
module Settlement
  class DataCleaner
    def self.call(user_id:)
      Settlement::Gathering.where(user_id: user_id).destroy_all
    end
  end
end
