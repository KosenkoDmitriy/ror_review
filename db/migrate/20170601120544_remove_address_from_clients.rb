class RemoveAddressFromClients < ActiveRecord::Migration[5.1]
  def change
    remove_column :clients, :address, :text
  end
end
