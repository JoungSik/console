class DropLegacyCollectionsAndTodos < ActiveRecord::Migration[8.1]
  def up
    drop_table :links, if_exists: true
    drop_table :collections, if_exists: true
    drop_table :todos, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
