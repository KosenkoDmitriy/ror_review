class NotificationType < ApplicationRecord
	belongs_to :notification_settings ,optional: true
end
