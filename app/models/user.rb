class User < ApplicationRecord
  resourcify
  belongs_to :client
  has_many :locations
  has_many :response_notes
  belongs_to :notification_settings ,optional: true
  accepts_nested_attributes_for :client
  rolify

  def self.search(search)
    roles = Role.all.map(&:name)
    if search.include?("@")
      where("email LIKE ?", "%#{search}%") 
    else
      User.where('first_name LIKE :search OR last_name LIKE :search', search: "%#{search}%")
    end
  end
  validates :password, :presence =>true,
                    :length => { :minimum => 6, :maximum => 40 },
                    :confirmation =>true
  validates :email, :presence => true, :uniqueness => true
  devise :database_authenticatable, :registerable,
         :recoverable,:rememberable

end


