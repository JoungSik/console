class CreateMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :members do |t|
      t.references :gathering, null: false, foreign_key: true
      t.string :name, null: false, limit: 50

      t.timestamps
    end
  end
end
