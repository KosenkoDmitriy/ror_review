class Request < ApplicationRecord
  has_one :response
  belongs_to :review_user


  def self.design_url(base, request_review)
    url = "#{base}/clients/request_review?request_id"+"="+"#{request_review}"
  end
end
