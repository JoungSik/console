class CreateBookmarkGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :groups do |t|
      t.string :title, null: false, limit: 100
      t.text :description
      t.boolean :is_public, null: false, default: false
      t.integer :links_count, null: false, default: 0
      t.integer :user_id, null: false

      t.timestamps
    end

    add_index :groups, :user_id
    add_index :groups, :is_public
  end
end
