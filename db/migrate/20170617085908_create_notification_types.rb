class CreateNotificationTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :notification_types do |t|
      t.string :notification_name
      t.string :description

      t.timestamps
    end
  end
end
