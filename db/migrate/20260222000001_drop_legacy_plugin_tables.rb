# 플러그인 아키텍처 전환으로 엔진별 독립 DB로 이동 완료
# primary DB에 남아있는 구 테이블 삭제
class DropLegacyPluginTables < ActiveRecord::Migration[8.0]
  def up
    # SQLite FK 제약 일시 비활성화 (자식→부모 순서 무관하게 삭제)
    execute "PRAGMA foreign_keys = OFF"
    drop_table :todo_items, if_exists: true
    drop_table :todo_lists, if_exists: true
    drop_table :collection_links, if_exists: true
    drop_table :collection_groups, if_exists: true
    execute "PRAGMA foreign_keys = ON"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
