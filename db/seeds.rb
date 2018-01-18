# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
# movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
# Character.create(name: 'Luke', movie: movies.first)
client = Client.create!(:name => 'superadmin')
role = Role.create!(:name => 'superadmin')
role.users.create!(:email => 'superadmin@gmail.com', :password => '123456' , :client_id => client.id , :first_name => 'Mark', :last_name => 'Jaundoo')

Role.create!(:name => 'Client')
Role.create!(:name => 'Admin')
Role.create!(:name => 'User')
Role.create!(:name => 'View')
Role.create!(:name => 'Demo')

NotificationType.create!(:notification_name => 'New Review',:description => 'Get the latest company news and product updates from Review Maiden')
NotificationType.create!(:notification_name => 'Blog',:description => 'Get the latest updates from our blog which include SEO tactics and ways to make improve your online reputation')
NotificationType.create!(:notification_name => 'Review Maiden News',:description =>'Get the latest company news and product updates from Review Maiden')
