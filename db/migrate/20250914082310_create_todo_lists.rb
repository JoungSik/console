class CreateTodoLists < ActiveRecord::Migration[8.0]
  def change
    create_table :todo_lists do |t|
      t.string :title, null: false, limit: 100
      t.references :user, null: false, foreign_key: true
      t.datetime :archived_at

      t.timestamps
    end
  end
end
