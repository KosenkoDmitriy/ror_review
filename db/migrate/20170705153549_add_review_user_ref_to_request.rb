class AddReviewUserRefToRequest < ActiveRecord::Migration[5.1]
  def change
    add_reference :requests, :review_user, foreign_key: true
  end
end
