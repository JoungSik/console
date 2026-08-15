class AddDeviceInformationToPushRegistrations < ActiveRecord::Migration[8.1]
  def change
    add_column :push_registrations, :device_model, :string
    add_column :push_registrations, :os_version, :string
    add_column :push_registrations, :app_version, :string
  end
end
