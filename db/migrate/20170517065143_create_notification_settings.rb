class CreateNotificationSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :notification_settings do |t|
      t.text :description
      t.string :notification_name
      t.boolean :email_notification_type
      t.boolean :push_notification_type

      t.timestamps
    end
  end
end
