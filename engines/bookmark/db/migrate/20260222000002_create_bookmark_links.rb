class CreateBookmarkLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :links do |t|
      t.references :group, null: false, foreign_key: true
      t.string :title, null: false, limit: 100
      t.text :url, null: false
      t.text :description
      t.string :favicon_url

      t.timestamps
    end
  end
end
