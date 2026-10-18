class CreatePluginPermissions < ActiveRecord::Migration[8.1]
  def change
    create_table :plugin_permissions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :plugin_name, null: false

      t.timestamps
    end
    add_index :plugin_permissions, %i[user_id plugin_name], unique: true
  end
end
