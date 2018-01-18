class AddNotificationTypesRefToNotificationSettings < ActiveRecord::Migration[5.1]
  def change
    add_reference :notification_settings, :notification_types, foreign_key: true
  end
end
