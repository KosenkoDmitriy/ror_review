class ApplicationMailer < ActionMailer::Base
  #default from: ENV["GMAIL_USERNAME"]
  layout 'mailer'
  def add_location_mail(email,params)
    @email = email
    @name = params[:location][:name] 
    @street = params[:location][:street]
    @country = params[:location][:location_country]
    @state = params[:location][:location_state]
    @city = params[:location][:location_city]
    @zipcode = params[:location][:zipcode]
    @user_name = params[:location][:user_name]
    @google_place_id = params[:location][:google_place_id]
    @google_location_id = params[:location][:google_location_id]
    @location_phone_no = params[:location][:location_phone_no]
    mail(to: ENV["SENDER_MAIL_USERNAME"], from: email, subject: "Request to add location")
  end
  def contact_sales(params)
    @name = params[:name] 
    @phone = params[:phone]
    @email = params[:email]
    @message = params[:message]
    mail(to: ENV["SENDER_MAIL_USERNAME"] , from: :email, subject: "Contact us mail")
  end
  
  def user_created(user)
    mail(to: user.email , from: ENV["SENDER_MAIL_USERNAME"], subject: "Create password")
  end

end
