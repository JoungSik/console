# 기존 테이블을 플러그인 엔진 구조에 맞게 이름 변경
# todos → todo_items, collections → bookmark_groups, links → bookmark_links
class RenameTablesForEngineArchitecture < ActiveRecord::Migration[8.0]
  def up
    # FK 제약 조건 제거 (테이블/컬럼 이름 변경 전)
    remove_foreign_key :todos, :todo_lists
    remove_foreign_key :links, :collections
    remove_foreign_key :todo_lists, :users
    remove_foreign_key :collections, :users

    # 테이블 이름 변경
    rename_table :todos, :todo_items
    rename_table :collections, :bookmark_groups
    rename_table :links, :bookmark_links

    # 컬럼 이름 변경
    rename_column :bookmark_links, :collection_id, :bookmark_group_id

    # 새로운 FK 제약 조건 추가
    add_foreign_key :todo_items, :todo_lists
    add_foreign_key :bookmark_links, :bookmark_groups
  end

  def down
    # FK 제약 조건 제거
    remove_foreign_key :todo_items, :todo_lists
    remove_foreign_key :bookmark_links, :bookmark_groups

    # 컬럼 이름 복원
    rename_column :bookmark_links, :bookmark_group_id, :collection_id

    # 테이블 이름 복원
    rename_table :bookmark_links, :links
    rename_table :bookmark_groups, :collections
    rename_table :todo_items, :todos

    # 기존 FK 제약 조건 복원
    add_foreign_key :todos, :todo_lists
    add_foreign_key :links, :collections
    add_foreign_key :todo_lists, :users
    add_foreign_key :collections, :users
  end
end
