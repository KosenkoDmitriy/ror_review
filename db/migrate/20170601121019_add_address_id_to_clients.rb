class AddAddressIdToClients < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :address_id, :integer
  end
end
