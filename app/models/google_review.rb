class GoogleReview < ApplicationRecord
  belongs_to :location
  belongs_to :client
  has_many :response_notes
end
