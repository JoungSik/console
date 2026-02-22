class CreateRoundMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :round_members do |t|
      t.references :round, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: true

      t.timestamps
    end

    add_index :round_members, [ :round_id, :member_id ], unique: true
  end
end
