class AddLocationPhoneNoToLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :locations, :location_phone_no, :string
  end
end
