class CreateNotices < ActiveRecord::Migration[8.1]
  def change
    create_table :notices do |t|
      t.string :title, null: false
      t.date :published_on, null: false
      t.date :expires_on
      t.integer :position, null: false
      t.timestamps
    end
  end
end
