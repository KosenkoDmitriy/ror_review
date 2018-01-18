class NotificationSetting < ApplicationRecord
  has_one :user
  has_many :notification_types
end

