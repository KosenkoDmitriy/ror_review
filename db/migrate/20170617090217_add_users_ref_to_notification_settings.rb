class AddUsersRefToNotificationSettings < ActiveRecord::Migration[5.1]
  def change
    add_reference :notification_settings, :users, foreign_key: true
  end
end
