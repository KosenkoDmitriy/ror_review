class DropClientSocialMedia < ActiveRecord::Migration[5.1]
  def change
    drop_table :client_social_media
  end
end
