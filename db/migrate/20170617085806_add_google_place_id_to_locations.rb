class AddGooglePlaceIdToLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :locations, :google_place_id, :string
  end
end
