class AddRoundingSeedToGatherings < ActiveRecord::Migration[8.1]
  def change
    add_column :gatherings, :rounding_seed, :integer
  end
end
