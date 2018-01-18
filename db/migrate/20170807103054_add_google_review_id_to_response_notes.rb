class AddGoogleReviewIdToResponseNotes < ActiveRecord::Migration[5.1]
  def change
    add_reference :response_notes, :google_review, foreign_key: true
  end
end
