class DropPushSubscriptions < ActiveRecord::Migration[8.1]
  def change
    drop_table :push_subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :endpoint, null: false
      t.string :p256dh_key, null: false
      t.string :auth_key, null: false
      t.timestamps

      t.index :endpoint, unique: true
    end
  end
end
