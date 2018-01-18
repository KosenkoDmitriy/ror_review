class AddAddressIdToLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :locations, :address_id, :integer
  end
end
