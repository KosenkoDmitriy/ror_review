class CreateResponses < ActiveRecord::Migration[5.1]
  def change
    create_table :responses do |t|
      t.boolean :positive
      t.string :url
      t.text :feedback
      t.boolean :google_review

      t.timestamps
    end
  end
end
