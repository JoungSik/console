class AddRemainderMethodToGatherings < ActiveRecord::Migration[8.0]
  def change
    add_column :gatherings, :remainder_method, :string, null: false, default: "ceil"
  end
end
