class CreateResponseNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :response_notes do |t|
      t.text :note_text
      t.references :user, foreign_key: true
      t.references :response, foreign_key: true

      t.timestamps
    end
  end
end
