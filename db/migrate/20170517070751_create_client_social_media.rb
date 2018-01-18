class CreateClientSocialMedia < ActiveRecord::Migration[5.1]
  def change
    create_table :client_social_media do |t|
      t.integer :location_id
      t.string :api_key
      t.string :url

      t.timestamps
    end
  end
end
