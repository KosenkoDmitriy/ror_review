class RemoveNotificationSettingIdFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :notification_setting_id, :integer
  end
end
