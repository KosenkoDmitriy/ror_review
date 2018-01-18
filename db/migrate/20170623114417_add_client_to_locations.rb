class AddClientToLocations < ActiveRecord::Migration[5.1]
  def change
    add_reference :locations, :clients, foreign_key: true
  end
end
