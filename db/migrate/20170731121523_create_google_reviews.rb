class CreateGoogleReviews < ActiveRecord::Migration[5.1]
  def change
    create_table :google_reviews do |t|
      t.string :google_review_id
      t.string :reviewer_name
      t.string :star_rating
      t.text :review_comment
      t.datetime :google_review_create_time
      t.datetime :google_review_update_time
      t.references :location, foreign_key: true
      t.references :client, foreign_key: true

      t.timestamps
    end
  end
end
