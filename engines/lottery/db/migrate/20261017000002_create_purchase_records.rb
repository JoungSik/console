class CreatePurchaseRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :purchase_records do |t|
      t.references :account, null: false, foreign_key: true
      t.date :purchased_on
      t.string :product_name, null: false
      t.integer :round
      t.string :order_no
      t.string :barcode
      t.integer :quantity, null: false, default: 0
      t.string :result
      t.integer :prize_amount, null: false, default: 0
      t.date :draw_date

      t.timestamps
    end

    add_index :purchase_records, [ :account_id, :purchased_on ]
  end
end
