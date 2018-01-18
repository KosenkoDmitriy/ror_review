class CreateClientResponses < ActiveRecord::Migration[5.1]
  def change
    create_table :client_responses do |t|
      t.text :client_reply
      t.references :user, foreign_key: true
      t.references :response, foreign_key: true

      t.timestamps
    end
  end
end
