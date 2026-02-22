class CreateGatherings < ActiveRecord::Migration[8.0]
  def change
    create_table :gatherings do |t|
      t.string :title, null: false, limit: 100
      t.date :gathering_date
      t.text :memo
      t.integer :user_id, null: false

      t.timestamps
    end

    add_index :gatherings, :user_id
  end
end
