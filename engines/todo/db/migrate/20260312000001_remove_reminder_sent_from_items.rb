class RemoveReminderSentFromItems < ActiveRecord::Migration[8.0]
  def change
    remove_column :items, :reminder_sent, :boolean, null: false, default: false
  end
end
