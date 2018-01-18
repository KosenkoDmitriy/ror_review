class RemoveReviewNoteFromResponse < ActiveRecord::Migration[5.1]
  def change
    remove_column :responses, :review_note, :text
  end
end
