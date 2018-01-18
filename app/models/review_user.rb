class ReviewUser < ApplicationRecord
  belongs_to :client
  has_many :requests
end
