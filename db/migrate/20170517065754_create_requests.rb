class CreateRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :requests do |t|
      t.integer :location_id
      t.string :email
      t.string :phone_no
      t.datetime :send_at
      t.boolean :clicked
      t.datetime :clicked_at
      t.string :url

      t.timestamps
    end
  end
end
