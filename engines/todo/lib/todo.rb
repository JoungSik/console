require "todo/version"

module Todo
  # 독립 DB를 사용하므로 테이블명에 네임스페이스 접두사를 붙이지 않는다.
  def self.table_name_prefix
    ""
  end
end

require "todo/engine"
