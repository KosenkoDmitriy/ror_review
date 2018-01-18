class Address < ApplicationRecord
  has_many :clients
  has_many :locations
end
