class CreatePushNotificationLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :push_notification_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.string :plugin_name
      t.string :item_key
      t.text :title, null: false
      t.text :body, null: false
      t.text :url
      t.integer :target_count, null: false, default: 0
      t.integer :success_count, null: false, default: 0
      t.integer :failure_count, null: false, default: 0
      t.json :targets, null: false, default: []
      t.datetime :requested_at, null: false
      t.datetime :completed_at

      t.timestamps
    end

    add_index :push_notification_logs, [ :user_id, :requested_at ]
    add_index :push_notification_logs, :status
  end
end
