class CreateTodoItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.string :title, null: false, limit: 200
      t.references :list, null: false, foreign_key: true
      t.boolean :completed, null: false, default: false
      t.date :due_date
      t.boolean :reminder_sent, null: false, default: false

      t.timestamps
    end
  end
end
