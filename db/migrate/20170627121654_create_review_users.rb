class CreateReviewUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :review_users do |t|
      t.string :name
      t.string :email
      t.string :phone_no
      t.references :client, foreign_key: true

      t.timestamps
    end
  end
end
