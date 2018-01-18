class AddGoogleLocationIdToLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :locations, :google_location_id, :string
  end
end
