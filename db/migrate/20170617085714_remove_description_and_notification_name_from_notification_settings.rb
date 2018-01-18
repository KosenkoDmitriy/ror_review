class RemoveDescriptionAndNotificationNameFromNotificationSettings < ActiveRecord::Migration[5.1]
  def change
    remove_column :notification_settings, :description, :text
    remove_column :notification_settings, :notification_name, :string
  end
end
