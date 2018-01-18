class AddGoogleClientIdToClients < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :google_client_id, :string
    add_column :clients, :google_secret_key, :string
    add_column :clients, :google_refresh_token, :string
    add_column :clients, :google_account_name, :string
  end
end
