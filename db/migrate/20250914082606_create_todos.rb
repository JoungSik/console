class CreateTodos < ActiveRecord::Migration[8.0]
  def change
    create_table :todos do |t|
      t.string :title, null: false, limit: 200
      t.references :todo_list, null: false, foreign_key: true
      t.boolean :completed, null: false, default: false
      t.date :due_date

      t.timestamps
    end
  end
end
