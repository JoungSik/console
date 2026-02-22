class CreateRounds < ActiveRecord::Migration[8.0]
  def change
    create_table :rounds do |t|
      t.references :gathering, null: false, foreign_key: true
      t.string :name, null: false, limit: 100
      t.integer :position, null: false, default: 0

      t.timestamps
    end
  end
end
