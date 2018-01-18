class ClientResponse < ApplicationRecord
  belongs_to :user
  belongs_to :response, optional: true
  belongs_to :google_review, optional: true
end
