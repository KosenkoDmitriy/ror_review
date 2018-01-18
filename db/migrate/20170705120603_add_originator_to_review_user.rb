class AddOriginatorToReviewUser < ActiveRecord::Migration[5.1]
  def change
    add_column :review_users, :originator, :string
  end
end
