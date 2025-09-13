class RemoveUserToLinks < ActiveRecord::Migration[8.0]
  def change
    remove_column :links, :user_id
  end
end
