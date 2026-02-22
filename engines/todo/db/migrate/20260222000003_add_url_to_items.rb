class AddUrlToItems < ActiveRecord::Migration[8.0]
  def change
    add_column :items, :url, :text
  end
end
