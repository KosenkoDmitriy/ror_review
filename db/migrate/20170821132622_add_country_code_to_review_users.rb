class AddCountryCodeToReviewUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :review_users, :country_code, :string
  end
end
