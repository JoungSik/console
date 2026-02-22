class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.references :round, null: false, foreign_key: true
      t.string :name, null: false, limit: 100
      t.integer :quantity, null: false, default: 1
      t.integer :amount, null: false, default: 0
      t.boolean :is_shared, null: false, default: false

      t.timestamps
    end
  end
end
