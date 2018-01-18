class CreateSubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :subscriptions do |t|
      t.date :next_billing_date
      t.references :client, foreign_key: true

      t.timestamps
    end
  end
end
