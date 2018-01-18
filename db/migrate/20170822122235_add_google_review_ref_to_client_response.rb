class AddGoogleReviewRefToClientResponse < ActiveRecord::Migration[5.1]
  def change
    add_reference :client_responses, :google_review, foreign_key: true
  end
end
