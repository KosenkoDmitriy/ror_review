class Client < ApplicationRecord
  has_many :users
  has_many :locations , through: :users
  belongs_to :address, optional: true
  has_many :templates
  has_many :subscriptions
  has_many :review_users

  accepts_nested_attributes_for :address


end
