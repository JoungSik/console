class CreateItemMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :item_members do |t|
      t.references :item, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: true

      t.timestamps
    end

    add_index :item_members, [ :item_id, :member_id ], unique: true
  end
end
