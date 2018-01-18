class CreateClients < ActiveRecord::Migration[5.1]
  def change
    create_table :clients do |t|
      t.string :name
      t.string :send_request_email
      t.string :send_request_mobile_no
      t.text :address

      t.timestamps
    end
  end
end
