# 플러그인별 데이터 삭제 인터페이스
# 각 플러그인 엔진에서 DataCleaner 클래스를 구현해야 한다.
module Console
  module PluginDataCleaner
    # @param plugin_name [String] 플러그인 이름 (예: "todos")
    # @param user_id [Integer] 삭제 대상 사용자 ID
    # @return [Boolean] 삭제 성공 여부
    def self.clean_data_for(plugin_name:, user_id:)
      cleaner_class = "#{plugin_name.to_s.classify}::DataCleaner"
      cleaner_class.constantize.call(user_id: user_id)
      true
    rescue NameError => e
      Rails.logger.warn("데이터 클리너 없음 [#{plugin_name}]: #{e.message}")
      false
    end
  end
end
