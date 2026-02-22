class AddUrlToItems < ActiveRecord::Migration[8.1]
  def change
    add_column :items, :url, :text
  end
end
