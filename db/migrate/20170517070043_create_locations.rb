class CreateLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :locations do |t|
      t.integer :user_id
      t.integer :email_template_id
      t.integer :phone_template_id
      t.string :office_location
      t.string :city
      t.string :state
      t.string :country

      t.timestamps
    end
  end
end
