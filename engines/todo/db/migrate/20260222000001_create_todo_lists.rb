class CreateTodoLists < ActiveRecord::Migration[8.0]
  def change
    create_table :lists do |t|
      t.string :title, null: false, limit: 100
      t.integer :user_id, null: false
      t.datetime :archived_at

      t.timestamps
    end

    add_index :lists, :user_id
  end
end
