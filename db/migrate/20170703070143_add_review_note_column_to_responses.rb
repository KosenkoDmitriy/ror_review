class AddReviewNoteColumnToResponses < ActiveRecord::Migration[5.1]
  def change
    add_column :responses, :review_note, :text
  end
end
