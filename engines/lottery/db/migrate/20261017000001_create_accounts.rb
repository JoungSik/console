class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.integer :user_id, null: false
      t.string :login_id, null: false
      t.string :password, null: false
      t.integer :total_deposit, null: false, default: 0
      t.integer :purchasable, null: false, default: 0
      t.datetime :synced_at

      t.timestamps
    end

    add_index :accounts, :user_id, unique: true
  end
end
