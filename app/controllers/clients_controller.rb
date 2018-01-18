class ClientsController < ApplicationController
  before_action :authenticate_user!, only: [:sendrequest_email, :sendrequest_sms, :auto_generate, :csv_heading, :bulk_send_request ]
  skip_before_action :verify_authenticity_token
  require 'sendgrid-ruby'
  include SendGrid 
  require 'json'
  require 'csv'
  @@current_loc=nil
  @@url_id=nil
  @@arrayName = []
  @@arrayEmail = [] 
  @@arrayPhone = []
  
  ##--
  ## Created By:NanRau
  ## Created On: 2/08/2017
  ## Purpose:To save the GMB account details of the client in client table 
  #++
  def update_gmb_account_details_for_client
    current_user.client.update(client_params)
    redirect_to clients_add_gmb_account_details_for_client_path, notice: t('.gmb_account_details') 
  end

  def add_gmb_account_details_for_client
   @client = current_user.client
  end


  ##--
  ## Created By:NanRau
  ## Created On: 6/06/2017
  ## Purpose:To get the positive google review by user
  #++
  def user_google_review
    @response = ApplicationRecord::Response.find(params[:id])
    @response.update(positive: true)
  end
  ##--
  ## Created By:NanRau
  ## Created On: 6/06/2017
  ## Purpose:To get the current location after selecting from dropdwon 
  #++
  def current_location
    @@current_loc = Location.find_by_address_id(params[:id])
  end

  ##--
  ## Created By:NanRau
  ## Created On: 6/06/2017
  ## Purpose: post method for google_review
  #++

  def google_request
    @response = ApplicationRecord::Response.find(params[:id])
    @response.update(google_review: true)
    flash[:success] = "Thanks for your google review "
  end 

  ##--
  ## Created By:NanRau
  ## Created On: 6/06/2017
  ## Purpose:get method for feedback
  #++
  def review_feedback
    @current_address = Address.find_by(:id => Location.find_by(:id => Request.find_by(:id => @@url_id).location_id).address_id)
    @response = ApplicationRecord::Response.find(params[:id])
    @response.update(positive: false)
  end

  ##--
  ## Created By:NanRau
  ## Created On: 6/06/2017
  ## Purpose:To save feedback in Response table 
  #++
  def user_feedback
    @response = ApplicationRecord::Response.find(params[:id])
    @response.update(feedback: params[:response][:feedback])
    redirect_to feedback_response_path
  end

  def feedback_response
    @current_address = Address.find_by(:id => Location.find_by(:id => Request.find_by(:id => @@url_id).location_id).address_id)
  end

   ##--
  ## Created By:NanRau
  ## Created On: 6/06/2017
  ## Purpose:To save params in Request table after link clicked .
  #++
  def request_review
    @@url_id = request.url.split('=').last  
    @current_loc_id = Location.find_by(:id => Request.find_by(:id => @@url_id).location_id).google_place_id
    @current_address = Address.find_by(:id => Location.find_by(:id => Request.find_by(:id => @@url_id).location_id).address_id)
    req = Request.find(params[:request_id])
    reminder_days = (Time.zone.now.to_date - req.send_at.to_date).to_i.days
    if reminder_days > 30.days
      redirect_to root_path, notice: t('.request_review')
    else
      req.update(clicked: true, clicked_at: Time.now)
      @review_response = ApplicationRecord::Response.new(request_id: req.id, url: request.url)
      @review_response.save
      send_notifications(req)
    end
  end

  #--
  ## Created By: ChTete
  ## Created On: 24/08/2017
  ## Purpose: For sending notifications, Retrive all the users and client for perticular notification 
  #++
  def send_notifications(request_id)
    location_id = request_id.location_id
    client_id = Location.find(location_id).clients_id
    user = User.where(:client_id => client_id)
    send_email_notification(user)
    send_sms_notification(user)
  end

  #--
  ## Created By: ChTete
  ## Created On: 24/08/2017
  ## Purpose: For sending email notifications
  #++
  def send_email_notification(users)
    new_review =  NotificationType.find_by(notification_name: "New Review")
    users.each do |user|
      if NotificationSetting.find_by(users_id: user.id, notification_types_id: new_review.id).email_notification_type   
        data = JSON.parse({
        "personalizations": [
          {
            "to": [
              {
                "email": user.email
              }
            ],
              "subject": new_review.notification_name
            }
          ],
        "from": {
          "email": "mark@reviewmaiden.com"
        },
        "content": [
          {
            "type": "text/html",
            "value": "New Review is Added in ReviewMaiden. "
          }                                                  
        ]
        }.to_json)                                                     
        send_grid = SendGrid::API.new(api_key:"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")
        response = send_grid.client.mail._("send").post(request_body: data) 
      end
    end
  end

  #--
  ## Created By: ChTete
  ## Created On: 24/08/2017
  ## Purpose: For sending push notifications
  #++
  def send_sms_notification(users)
    new_review =  NotificationType.find_by(notification_name: "New Review")
    users.each do |user|
      if NotificationSetting.find_by(users_id: user.id, notification_types_id: new_review.id).push_notification_type        
        begin 
          client = Twilio::REST::Client.new ENV["TWILIO_ACC_SID"], ENV["TWILIO_AUTH_TOKEN"]
          response = client.messages.create(
            from: ENV["TWILIO_NO"],
            to:   user.primary_mobile_no,
            body: "New Review is Added in ReviewMaiden. "
          )
        rescue Twilio::REST::RequestError => twillio_error
          # return e.message
        end
      end
    end
  end

  #--
  ## Created By: Kri
  ## Created On: 24/05/2017
  ## Purpose: For selecting input based on params
  #++

  def send_request
    sendrequest_email if (params[:email] == "email" ) 
    sendrequest_sms if (params[:email] == "phone_no")            # Checking the input params 
    redirect_to home_index_path
  end   

  #--
  ## Created By: Kri
  ## Created On: 24/05/2017
  ## Purpose: For sending email through index page
  #++
  
  def sendrequest_email
    if current_user.client.templates.exists? && ((current_user.client.templates.first.is_email == true) || (current_user.client.templates.last.is_email == true))
      templates=current_user.client.templates.where(:is_email => 1)
      trf=templates.pluck.last            #trf is variable for storing T (or) F value
      template=trf[5]                     #rews means reviews_users(table name)
      @email = params[:revws][:phone_no]                
      name = params[:revws][:name]
      orig =current_user.client.originator                            #orig is used for storing originator temporarily
      review_sent = current_user.client.review_users.create(:email => @email,:name => name,:originator => orig)      
      base = request.base_url
      Request.create(:review_user_id => review_sent.id, location_id:  @@current_loc.id,send_at: Time.now)
      requestData = Request.where(:review_user_id => ReviewUser.ids).last
      url = Request.design_url(base,requestData.id)
      #START--code for send review link 
      template_text = current_user.client.templates.where(:is_email => 1).last.template_text
      if template_text.include? "$review_link$"
        template_text = template_text.gsub("$review_link$", " #{url} ")
      else
        template_text = template_text.concat(" #{url} ")
      end
      #END--code for send review link 
      requestData.update(url: url) if url
      data = JSON.parse({
        "personalizations": [
          {
            "to": [
              {
                "email": params[:revws][:phone_no]
              }
            ],
            "subject": "#{template}"
          }
        ],
        "from": {
          "email": "mark@reviewmaiden.com"
        },
        "content": [
          {
            "type": "text/html",
            "value": "#{template_text}"
          }                                                  
        ]
      }.to_json)                                                     
      send_grid = SendGrid::API.new(api_key:"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")
      response = send_grid.client.mail._("send").post(request_body: data)                              # send_grid is the variable for storing api_key
      flash[:notice] = 'Successfully Sent Request'
    else
      flash[:notice] = 'Please Add Template'
    end
  end
  

  #--
  ## Created By: Vikas
  ## Created On: 24/05/2017
  ## Purpose: For sending sms through index page
  #++

  def sendrequest_sms
    if current_user.client.templates.exists? && ((current_user.client.templates.first.is_email == false) || (current_user.client.templates.last.is_email == false))
      begin
        templates=current_user.client.templates.where(:is_email => 0)
        phone_no = params[:revws][:phone_no]
        name = params[:revws][:name]        
        orig =current_user.client.originator
        country_code = params[:revws][:country]
        country_code = country_code.split('(').last
        country_code = country_code.tr('()', '')
        review_sent = current_user.client.review_users.create(:phone_no => phone_no,:name => name,:originator => orig,:country_code=>country_code)      
        base = request.base_url
        Request.create(:review_user_id => review_sent.id, location_id:  @@current_loc.id,send_at: Time.now)
        requestData = Request.where(:review_user_id => ReviewUser.ids).last
        url = Request.design_url(base,requestData.id)
        #START--code for send review link 
        template_text = templates.last.template_text
        if template_text.include? "$review_link$"
          template_text = template_text.gsub("$review_link$", "#{url}")
        else
          template_text = template_text.concat (" #{url} ")
        end
        #END--code for send review link 
        requestData.update(url: url) if url
        phone_number = extract_country_code
        client = Twilio::REST::Client.new ENV["TWILIO_ACC_SID"], ENV["TWILIO_AUTH_TOKEN"]
        response = client.messages.create(
          from: ENV["TWILIO_NO"],
          to:   phone_number,
          body: "#{template_text}"
        ) 
        flash[:notice] = 'Successfully Sent Request'
        rescue Twilio::REST::RequestError => twillio_error
          flash[:message] = twillio_error   
      end   
    else
      flash[:notice] = 'Please Add Template'
    end
  end
  
  
  #--
  ## Created By: RahKan 
  ## Created On: 17/08/2017
  ## Purpose: To extract the country code from selected country
  #++
  def extract_country_code
    if !params[:revws][:phone_no].include? "+"
      country_code = params[:revws][:country]
      country_code = country_code.split('(').last
      country_code = country_code.split(')').first+params[:revws][:phone_no]
    else
      country_code = params[:revws][:phone_no]
    end 
  end

  #--
  ## Created By: Kris
  ## Created On: 24/05/2017
  ## Purpose: Creating Template for sending Review requests 
  #++
  
  def template
    @template = current_user.client.templates.where(is_email: true).last
    @template_sms = current_user.client.templates.where(is_email: false).last
    location_id = current_user.locations.ids rescue nil
    @reviews = GoogleReview.where(location_id: location_id).count rescue nil
    request_count_and_request_pending
  end

  def create_template
    tmplt_txt = params[:templates][:template_text]        #tmplt_txt for storing template_text temporarily
    eml_subj = params[:templates][:email_subject] 
    # if tmplt_txt !=" " && eml_subj !=" "        #eml_subj for storing email_subject temporarily
    if eml_subj != nil
     template =  current_user.client.templates.create(:template_text => tmplt_txt, :email_subject => eml_subj, :is_email => true )
       flash[:success] = "Email Template Added Successfully."
    else
      current_user.client.templates.create(:template_text => tmplt_txt,:is_email => false )
      flash[:success] = "Sms Template Added Successfully."
    end
    redirect_to clients_template_path
  end

  def edit_sms
    @template = current_user.client.templates.where(is_email: false).last
  end

  def update_client_sms
    @template = Template.find_by(id: params[:id])
    template_text = params[:template][:template_text]
    @template.update_attributes(template_text: template_text, is_email: false) 
    flash[:success] = "Sms Template Edited Successfully."
    redirect_to clients_template_path 
  end

  def edit
    @template = current_user.client.templates.where(is_email: true).last
  end
  
  def update_client
    @template = Template.find_by(id: params[:id])
    template_text = params[:template][:template_text]
    @template.update_attributes(email_subject: params[:template][:email_subject], template_text: template_text, is_email: true)
    flash[:success] = "Email Template Edited Successfully."
    redirect_to clients_template_path 
  end

  #--
  ## Created By: Kris
  ## Created On: 23/06/2017
  ## Purpose: for generating automatically name field when client types phone/email  
  #++

  def auto_generate
    phone = params[:phone_no] 
    email = params[:phone_no]
    if !phone.match(/^(\+\d{1,3}[-]?)?\d{10}$/).nil?
      name = ReviewUser.where(phone_no: phone)
      names = name.pluck(:name)
      names.size != 1
      originators = name.pluck(:originator)
      render json: {names: names, originators: originators}
    elsif !phone.match(/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/).nil?
      name = ReviewUser.where(email: email)
      names = name.pluck(:name)
      names.size != 1
      originators = name.pluck(:originator)
      render json: {names: names, originators: originators}
    else
      render json: {names: names}
    end
  end

  #--
  ## Created By: Chtete
  ## Created On: 28/06/2017
  ## Purpose: For checking csv file column headings
  #++
  
  def csv_heading
    @@csv_data = ''
    @@arrayName = []
    @@arrayEmail = [] 
    @@arrayPhone = []
    email_reg =  Regexp.union(/em/,/id/,/ma/,/add/,/EMAIL/,/email/,/Email/)
    phone_reg = Regexp.union(/ph/,/mo/,/co/,/no/,/nu/,/on/,/Phone/)
    name_reg =   Regexp.union(/na/,/cl/,/me/,/NAME/,/name/,/Name/)
    filename = params[:file].tempfile
    if file_extension = File.extname(filename) != ".csv"
      flash[:notice] = 'Only .csv formats are allowed.'
    else
      @@csv_data = CSV.read( params[:file].tempfile, :headers=>false) 
        @@csv_data[0].each do |i|
          CSV.foreach(params[:file].tempfile, :headers => true) do |row| 
            if !(name_reg.match(i)).nil?
              @@arrayName.push(row[i])
            elsif !(email_reg.match(i)).nil?
              @@arrayEmail.push(row[i])
            else
              @@arrayPhone.push(row[i])
            end
          end
        end
    end
    render json: {csv_data: @@csv_data[0], csv_data_all: @@csv_data}
  end

  #--
  ## Created By: Chtete
  ## Created On: 28/06/2017
  ## Purpose: For Sending Bulk Request
  #++
  
  def bulk_send_request        
    email_reg =  Regexp.union(/em/,/id/,/ma/,/add/,/EMAIL/,/email/,/Email/)
    phone_reg = Regexp.union(/ph/,/mo/,/co/,/no/,/nu/,/on/,/Phone/)
    name_reg =   Regexp.union(/na/,/cl/,/me/,/NAME/,/name/,/Name/)
    row1 = []
    row2 = []
    row3 = []
    sequenceRow =[]
    chkNames = params[:chkNames]
    selects = params[:selects]
    skipDuplicates = params[:skipDuplicates]
    address_id = Location.find_by_address_id(params[:address_id_bulk]).id

    if !(name_reg.match(chkNames[0])).nil?
      row1 = @@arrayName
      sequenceRow.push("name")
    elsif !(email_reg.match(chkNames[0])).nil?
      row1 = @@arrayEmail
      sequenceRow.push("email")
    else 
      row1 = @@arrayPhone
      sequenceRow.push("phone")  
    end
    if !(name_reg.match(chkNames[1])).nil?
      row2 = @@arrayName
      sequenceRow.push("name")
    elsif !(email_reg.match(chkNames[1])).nil?
      row2 = @@arrayEmail
      sequenceRow.push("email")
    else
      row2 = @@arrayPhone
      sequenceRow.push("phone")
    end
    if !(name_reg.match(chkNames[2])).nil?
      row3 = @@arrayName
      sequenceRow.push("name")
    elsif !(email_reg.match(chkNames[2])).nil?
      row3 = @@arrayEmail
      sequenceRow.push("email")
    else
      row3 = @@arrayPhone
      sequenceRow.push("phone")
    end
    @@arrayPhone = []
    @@arrayEmail = [] 
    removeRow = []
    removeEmail = []
    removePhone =[]
    sucessfully_import =0 
    duplicates_skipped = 0
    error_found = 0
    # checking which row contains email and phones
    if sequenceRow.at(0) =="email" and sequenceRow.at(1)=="phone"
      @@arrayPhone = row2
      @@arrayEmail = row1
    elsif sequenceRow.at(0) =="phone" and sequenceRow.at(1)=="email"
      @@arrayPhone = row1
      @@arrayEmail = row2
    elsif sequenceRow.at(0)=="name" and sequenceRow.at(1)=="email"
      @@arrayPhone = row3
      @@arrayEmail = row2
    elsif sequenceRow.at(0)=="name" and sequenceRow.at(1)=="phone"
      @@arrayPhone = row2
      @@arrayEmail = row3
    elsif sequenceRow.at(0) =="phone" and sequenceRow.at(1)=="name"
      @@arrayPhone = row1
      @@arrayEmail = row3
    else 
      @@arrayPhone = row3
      @@arrayEmail = row1
    end
    #checking for email pattern
    (0...@@arrayName.length).each do |index| 
      if !@@arrayEmail[index].nil? and !(matched = @@arrayEmail[index].match(/\A[^@\s]+@[^@\s]+\z/)).nil?
        #checking for duplicates email 
        if  skipDuplicates == "yes"
          if ReviewUser.where(:email => @@arrayEmail[index]).exists?
            removeRow.push(index)
            removeEmail.push(index)
            duplicates_skipped = duplicates_skipped+1
          end
        end
      # checking for phones pattern
      elsif !@@arrayPhone[index].nil? and !(matched = @@arrayPhone[index].match(/^\+(?:[0-9] ?){7,15}[0-9]$/)).nil?
        #checking for duplicate phones
        if  skipDuplicates == "yes"
          if ReviewUser.where(:phone_no => @@arrayPhone[index]).exists?
            removeRow.push(index)
            removePhone.push(index)
            duplicates_skipped = duplicates_skipped +1
          end
        end    
      else 
        removeRow.push(index)
        error_found = error_found+1
      end
    end
    #removing unwanted elements/duplicates having errors
    if removePhone !=nil
      removePhone.each do |index| 
        @@arrayPhone[index] = nil
       end
    end
    if removeEmail !=nil 
      removeEmail.each do |index| 
        @@arrayPhone[index] = nil
       end
    end
    if removeRow !=nil 
      removeRow.each do |index| 
        row1[index] = nil
        row2[index] = nil
        row3[index] = nil
      end
    end

    if row1!=nil  
      (0...row1.length).each do |index| 
        if !(row1[index] ==nil and  row2[index] ==nil and  row3[index] ==nil)  
          sucessfully_import = sucessfully_import+1        
          reviewUser = ReviewUser.create("#{selects[0]}": row1[index], "#{selects[1]}": row2[index], "#{selects[2]}": row3[index], originator: params[:originator], client_id: current_user.client_id)
          Request.create(:review_user_id => reviewUser.id, location_id: address_id, send_at: Time.now)
        end
      end
    end
    # sending email using sendgrid
    @@arrayEmail.each do |users_email|  
      if users_email != nil
        begin     
          reviewUser = ReviewUser.where(:email => users_email) 
          reviewUser=  reviewUser.last
          requestData = Request.find_by(:review_user_id => reviewUser.id)
          base = request.base_url
           url = Request.design_url(base,requestData.id)
          requestData.update(url: url) if url
          data = JSON.parse({
          "personalizations": [
            {
              "to": [
                {
                  "email": users_email
                }
              ],
              "subject": "#{current_user.client.templates.last.template_text}"
            }
          ],
           "from": {
            "email": "mark@reviewmaiden.com"
           },
           "content": [
            {
              "type": "text/plain",
              "value": "#{url}"
            }
          ]
          }.to_json)
          send_grid = SendGrid::API.new(api_key: "55ifw1AeR4W0tHOPsARgAw",host: 'https://api.sendgrid.com')
          response = send_grid.client.mail._("send").post(request_body: data)
        rescue SendGrid::API::RequestError => e
          return e.message
        end
      end
    end
    # sending sms using twilio
    @@arrayPhone.each do |users_phone_number|
      if users_phone_number != nil
        begin 
          reviewUser = ReviewUser.where(:phone_no => users_phone_number) 
          reviewUser=  reviewUser.last
          requestData = Request.find_by(:review_user_id => reviewUser.id)
          base = request.base_url
          url = Request.design_url(base,requestData.id)
          requestData.update(url: url) if url    
          client = Twilio::REST::Client.new ENV["TWILIO_ACC_SID"], ENV["TWILIO_AUTH_TOKEN"]
          response = client.messages.create(
            from: ENV["TWILIO_NO"],
            to:   users_phone_number,
            body: "#{current_user.client.templates.last.template_text} #{url} "
          )
          rescue Twilio::REST::RequestError => e
            # return e.message
        end
      end
    end 
    render json: {duplicates_skipped: duplicates_skipped,sucessfully_import:sucessfully_import,error_found:error_found  }
  end

  def privacy_policy
  end



  def request_count_and_request_pending
    loc_id = current_user.locations.first.id rescue nil
    @count = 0
    date = (Time.now).strftime("%m")  
    requests = Request.where(:location_id => loc_id)
    resp = ApplicationRecord::Response.where(:request_id => requests)
    respons = resp.where('extract(month from created_at) = ?', date)
    counts = respons.pluck(:feedback) rescue nil
    counts.each do |cnt|
      if (cnt==nil)
        @count = @count + 1
      end
    end
    date_previous = (Time.now - 1.month).strftime("%m") 
    requests1 = Request.where(:location_id=> loc_id)
    @request_count = requests1.where('extract(month from send_at) = ?', date_previous).count  
  end



  def created_password
    user_id = request.url.split("/").last
    @user = User.find(user_id)
  end

  def created_passwords
    @user = User.find_by(:id => params[:user][:id])
    @user.update(password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])
    redirect_to user_session_path 
    flash[:notice] = 'Password is created sucessfully'
  end
  
  protected
    def client_params
      params.require(:client).permit(:google_client_id, :google_secret_key, :google_refresh_token, :google_account_name)
    end
     def template_params
    params.require(:templates).permit(:email_subject, :template_text)
    end

  

end

 