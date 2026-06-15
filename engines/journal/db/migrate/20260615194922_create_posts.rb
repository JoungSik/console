class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.integer :user_id, null: false
      t.text :body, null: false

      t.timestamps
    end

    add_index :posts, [ :user_id, :created_at ]
  end
end
