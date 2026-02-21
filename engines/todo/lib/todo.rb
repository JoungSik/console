require "todo/version"

module Todo
  # DB가 분리되어 있으므로 테이블명에 네임스페이스 접두사 불필요
  def self.table_name_prefix
    ""
  end
end

require "todo/engine"
