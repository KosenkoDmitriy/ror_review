class RemoveCityFromLocations < ActiveRecord::Migration[5.1]
  def change
    remove_column :locations, :office_location, :text
    remove_column :locations, :city, :string
    remove_column :locations, :state, :string
    remove_column :locations, :country, :string
  end
end
