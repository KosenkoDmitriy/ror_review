module ApplicationHelper
  def addresses
    if current_user.has_role?(:Client)
      address = current_user.client.locations.pluck(:address_id)
      @address =  Address.where("id in (?)", address) 
    elsif !current_user.has_role?(:Client)
       #address = current_user.client.users.first.locations.pluck(:address_id)
       address  = current_user.locations.pluck(:address_id)
       @address =  Address.where("id in (?)", address)
    end
  end
  def device_name
    user_agent =  request.env['HTTP_USER_AGENT'].downcase
    user_agent_data = AgentOrange::UserAgent.new(user_agent)
    device = user_agent_data.device
  end

  def countrie_codes
    countries = []
    CS.countries.reject!{|k| k == :COUNTRY_ISO_CODE}.reject!{|k| k == :XK}.each do |eds|
      countries.push(eds[1]+"(+"+ISO3166::Country[eds[0]].country_code+")")
    end
    return countries    
  end

  def setting_notification(notify_id)
    email_notification = NotificationSetting.find_by(:users_id => current_user.id, notification_types_id: notify_id).email_notification_type? 
    push_notification = NotificationSetting.find_by(:users_id => current_user.id, notification_types_id: notify_id).push_notification_type? 
    return email_notification, push_notification
  end
  def clients_listing
    client_ids=Client.all.ids
    users=User.where('active != ?', "0")
    user=users.where(:client_id=>client_ids)
    client_id=user.pluck(:client_id)
    client_id=client_id.uniq
    @client_name=Client.where(:id => client_id)
  end
end
