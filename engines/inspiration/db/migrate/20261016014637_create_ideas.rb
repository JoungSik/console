class CreateIdeas < ActiveRecord::Migration[8.1]
  def change
    create_table :ideas do |t|
      t.integer :user_id, null: false
      t.string :title, null: false
      t.text :body
      t.string :reference_url
      t.integer :status, null: false, default: 0
      t.integer :notes_count, null: false, default: 0

      t.timestamps
    end

    add_index :ideas, [ :user_id, :updated_at ]
    add_index :ideas, [ :user_id, :status ]
  end
end
