class AddRecurrenceToItems < ActiveRecord::Migration[8.1]
  def change
    add_column :items, :recurrence, :string
    add_column :items, :recurrence_ends_on, :date
    add_column :items, :recurrence_parent_id, :integer

    add_index :items, :recurrence_parent_id
  end
end
