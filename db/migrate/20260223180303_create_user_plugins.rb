class CreateUserPlugins < ActiveRecord::Migration[8.1]
  def change
    create_table :user_plugins do |t|
      t.references :user, null: false, foreign_key: true
      t.string :plugin_name, null: false
      t.boolean :enabled, null: false, default: true
      t.datetime :disabled_at

      t.timestamps
    end

    add_index :user_plugins, [ :user_id, :plugin_name ], unique: true
  end
end
