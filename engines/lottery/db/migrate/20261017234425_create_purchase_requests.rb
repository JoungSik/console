class CreatePurchaseRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :purchase_requests do |t|
      t.references :account, null: false, foreign_key: true
      t.string :token, null: false

      t.timestamps
    end

    add_index :purchase_requests, :token, unique: true
  end
end
