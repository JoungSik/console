class RemoveRemainderMethodFromGatherings < ActiveRecord::Migration[8.1]
  def change
    remove_column :gatherings, :remainder_method, :string, default: "ceil", null: false
  end
end
