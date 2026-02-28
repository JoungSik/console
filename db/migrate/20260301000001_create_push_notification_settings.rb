class CreatePushNotificationSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :push_notification_settings do |t|
      t.references :user, null: false, foreign_key: true
      t.string :plugin_name, null: false
      t.string :item_key, null: false
      t.boolean :enabled, null: false, default: true

      t.timestamps
    end

    add_index :push_notification_settings, %i[user_id plugin_name item_key], unique: true, name: "idx_push_notif_settings_unique"
  end
end
