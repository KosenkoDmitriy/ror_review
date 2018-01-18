class HomeController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, :only => [:send_request_add_location]  
  respond_to :js, :json, :html, only: :get_billing_client_date
  require 'rest-client'
  require 'json'

  ##--
  ## Created By: MohSwaz
  ## Created On: 19/07/2017
  ## Purpose: To show request pending and request count on page load. In dashboard page,Reviews page,Locations page and in the requests page.
  #++

  def request_count_and_request_pending
    loc_id = current_user.locations.first.id rescue nil
    @count = 0
    date = (Time.now).strftime("%m")  
    requests = Request.where(:location_id => loc_id)
    resp = Response.where(:request_id => requests)
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

  ##--
  ## Created By: MohSwaz
  ## Created On: 09/08/2017
  ## Purpose: To show the reviews on reviews page on first load.
  #++
  def reviews
    loc_id = current_user.locations.first.id rescue nil
    @responses = Response.where(:request_id => (Request.where(:location_id => loc_id).ids)).order('created_at DESC') 
    @loc_google_reviews = GoogleReview.where(location_id: loc_id ).order('google_review_create_time DESC') rescue nil
    reviews =  @loc_google_reviews.count 
    request_count_and_request_pending
    render :template => 'home/reviews', :locals => {:reviews => reviews}
  end

  ##--
  ## Created By: MohSwaz
  ## Created On: 09/08/2017
  ## Purpose: To show the reviews on reviews page on location change.
  #++
  def reviews_location
    if params[:client_id]!=nil
      client_id = params[:client_id]
      users_id = User.find_by(client_id: client_id).id
      locations = Location.where(user_id: users_id)
      address_ids = locations.all.collect {|p| p.address_id}
      address = Address.all.where(:id => address_ids)
      #for showing reviews on index and reviews page for first location of selected client. 
      first_location = locations.first.id rescue nil
      google_reviews = GoogleReview.where(location_id: first_location).order('google_review_update_time DESC') rescue nil
      responses = Response.where(:request_id => (Request.where(:location_id => first_location).ids)).order('created_at DESC') rescue nil
    else
      loc_id = Address.find(params[:id]).locations.first.id
      responses = Response.where(:request_id => (Request.where(:location_id => loc_id).ids)).order('created_at DESC') rescue nil
      google_reviews = GoogleReview.where(location_id: loc_id).order('google_review_update_time DESC') rescue nil
    end
    response_notes = ResponseNote.all.order("created_at DESC")
    client_response = ClientResponse.all.order("created_at DESC")
    isclient = current_user.has_role?(:Client)
    responses = responses.order('created_at DESC')
    render json: {responses: responses, google_reviews: google_reviews, response_notes: response_notes, client_response: client_response, isclient: isclient, addresses: address  }
  end

  ##--
  ## Created By: MohSwaz
  ## Created On: 27/07/2017
  ## Purpose: To filter positive and negative reviews by current day, current week, all and by selected date.
  #++

 def filter_reviews
    if params[:filter] == "filter_by_day"
      add_id = params[:data]
      loc_id = Location.find_by_address_id(add_id) rescue nil
      req_ids = Request.where(:location_id => loc_id).ids 
      respons = Response.where("created_at >= ?", Time.zone.now.beginning_of_day)
      responses=respons.where(:request_id => req_ids).order('created_at DESC')
      filter_google_reviews = GoogleReview.where("google_review_create_time >= ? AND location_id = ?",Time.zone.now.beginning_of_day, loc_id).order('google_review_update_time DESC') rescue nil
    elsif params[:filter] == "filter_by_week"
      add_id = params[:data]
      loc_id = Location.find_by_address_id(add_id) rescue nil
      req_ids = Request.where(:location_id => loc_id).ids
      respons = Response.where("created_at >= ?", Time.zone.now.beginning_of_week)
      responses=respons.where(:request_id => req_ids).order('created_at DESC')
      filter_google_reviews = GoogleReview.where("google_review_create_time >= ? AND location_id = ?",Time.zone.now.beginning_of_week, loc_id).order('google_review_update_time DESC') rescue nil
    elsif params[:filter] == "filter_by_month"
      add_id = params[:data]
      loc_id = Location.find_by_address_id(add_id) rescue nil
      req_ids = Request.where(:location_id => loc_id).ids
      respons = Response.where("created_at >= ?", Time.zone.now.beginning_of_month)
      responses=respons.where(:request_id => req_ids).order('created_at DESC')
      filter_google_reviews = GoogleReview.where("google_review_create_time >= ? AND location_id = ?",Time.zone.now.beginning_of_month, loc_id).order('google_review_update_time DESC') rescue nil
    elsif params[:filter] == "view_all_new"
      loc_id = params[:location_id]
      req_ids = Request.where(:location_id => loc_id).ids
      responses = Response.where(:request_id => (Request.where(:location_id => loc_id).ids)).order('created_at DESC') rescue nil
      filter_google_reviews = GoogleReview.where(location_id: loc_id).order('google_review_update_time DESC') rescue nil
    else 
      add_id = params[:data]
      loc_id = Location.find_by_address_id(add_id) rescue nil
      req_ids = Request.where(:location_id => loc_id).ids    
      date = Date.strptime(params[:date], "%m/%d/%Y").strftime("%Y/%m/%d")
      respons = Response.where("DATE(created_at) = ?", date)
      responses=respons.where(:request_id => req_ids).order('created_at DESC')
      filter_google_reviews = GoogleReview.where("DATE(google_review_create_time) = ? AND location_id = ?",date, loc_id).order('google_review_update_time DESC') rescue nil
    end
    response_notes = ResponseNote.all.order("created_at DESC")
    client_response = ClientResponse.all.order("created_at DESC")
    isclient=current_user.has_role?(:Client)
    render json: {responses: responses, filter_google_reviews: filter_google_reviews, response_notes: response_notes, isclient: isclient, client_response: client_response}
  end

  ##--
  ## Created By: MayKan
  ## Created On: 21/06/2017
  ## Purpose: To show bar graph according to the location selected in dropdown.
  #++

  def chart_data
    @response_month_name = {}
    @response_gmonth_name = {}
    positive = []
    negative = []
    location_id = current_user.locations.ids rescue nil
    reviews = Response.where(:request_id => (Request.where(:location_id => location_id).ids)).all
    if params[:id] == nil
      loc_id = current_user.locations.first.id rescue nil
      @responses = Response.where(:request_id => (Request.where(:location_id => loc_id).ids)) rescue nil 
    elsif params[:client_id]!=nil
      client_id = params[:client_id]
      users_id = User.find_by(client_id: client_id).id
      locations = Location.where(user_id: users_id)
      address_ids = locations.all.collect {|p| p.address_id}
      address = Address.all.where(:id => address_ids)
      first_location = locations.first.id rescue nil
      @google_reviews = GoogleReview.where(location_id: first_location).order('google_review_create_time DESC') rescue nil
      @googlereviews = GoogleReview.where(location_id: first_location) rescue nil
      greviews = @googlereviews.all.group('extract(month from google_review_create_time)').count
      greviews.each do |month_no, count|
        month_name = Date::MONTHNAMES[month_no]
        @response_gmonth_name[month_name] = count
      end
      @responses = Response.where(:request_id => (Request.where(:location_id => first_location).ids)) rescue nil 
      date = (Time.now - 1.month).strftime("%m") 
      @requests1 = Request.where(:location_id=> first_location)
      @count = @requests1.where('extract(month from send_at) = ?', date).count
    else
      add_id = params[:id] 
      loc_id = Location.find_by_address_id(add_id) rescue nil
      @responses = Response.where(:request_id => (Request.where(:location_id => loc_id).ids)) rescue nil
      date = (Time.now - 1.month).strftime("%m") 
      @requests1 = Request.where(:location_id=> loc_id.id)
      @count = @requests1.where('extract(month from send_at) = ?', date).count
      @google_reviews = GoogleReview.where(location_id: loc_id).order('google_review_create_time DESC') rescue nil
    end
    response = @responses.all.group('extract(month from created_at)').count
    response.each do |month_no, count|
      month_name = Date::MONTHNAMES[month_no]
      @response_month_name[month_name] = count
    end
    @responses = @responses.order('created_at DESC')
    @googlereviews = GoogleReview.where(location_id: loc_id) rescue nil
    greviews = @googlereviews.all.group('extract(month from google_review_create_time)').count
    greviews.each do |month_no, count|
      month_name = Date::MONTHNAMES[month_no]
      @response_gmonth_name[month_name] = count
    end
    response_notes = ResponseNote.all.order("created_at DESC")
    client_response = ClientResponse.all.order("created_at DESC")
    isclient = current_user.has_role?(:Client)
    months_all = (@response_month_name.keys+@response_gmonth_name.keys).uniq  
    months_all.each_with_index { |val|
      negative.push(@response_month_name[val])
      positive.push(@response_gmonth_name[val])
    }
    render json: {addresses: address,months_all: months_all,chart_data: negative, google_data: positive, Review_data: @responses, response_notes: response_notes, Request_count: @count, Google_reviews: @google_reviews, isclient: isclient, client_response: client_response }
  end

  ##--
  ## Created By: MohSwaz
  ## Created On: 09/06/2017
  ## Purpose: To show bar graph if the user is superadmin it will display all the list of review response of year.
  ## if user is client then  it will display bar graph of first location of current user.
  #++


  def index
    @response_month_name = {}
    @response_gmonth_name = {}
    location_id = current_user.locations.ids rescue nil
    reviews = GoogleReview.where(location_id: location_id).count rescue nil
    if params[:id] == nil
      loc_id = current_user.locations.first.id rescue nil
      @responses = Response.where(:request_id => (Request.where(:location_id => loc_id).ids)) rescue nil
      response = @responses.all.group('extract(month from created_at)').count
      @responses = @responses.order('created_at DESC')
      request_count_and_request_pending
    else
      add_id = params[:id] 
      loc_id = Location.find_by_address_id(add_id) rescue nil
      @responses = Response.where(:request_id => (Request.where(:location_id => loc_id).ids)) rescue nil
      response = @responses.all.group('extract(month from created_at)').count
    end
    response.each do |month_no, count|
      month_name = Date::MONTHNAMES[month_no]
      @response_month_name[month_name] = count
    end
    isclient = current_user.has_role?(:Client)
    @google_reviews = GoogleReview.where(location_id: loc_id).order('google_review_create_time DESC') rescue nil
    @googlereviews = GoogleReview.where(location_id: loc_id) rescue nil
    greviews = @googlereviews.all.group('extract(month from google_review_create_time)').count
    greviews.each do |month_no, count|
      month_name = Date::MONTHNAMES[month_no]
      @response_gmonth_name[month_name] = count
    end  
    render :template => 'home/index', :locals => {:reviews => reviews, :isclient => isclient}
  end

  ##--
  ## Created By: PiyPan
  ## Created On: 19/07/2017
  ## Purpose: Count Total # of Reviews(Overall)
  #++
  def total_reviews
    if current_user.has_role? :superadmin
      client_id = params[:client_id]
      users_id = User.find_by(client_id: client_id).id
      location_id = Location.where(user_id: users_id)
      @g_reviews = GoogleReview.where(location_id: location_id).count rescue nil
      render json: {reviews: @g_reviews}
    end
  end
  
  ##--
  ## Created By: PiyPan
  ## Created On: 14/07/2017
  ## Purpose: Request Pending count of current month
  #++
  def request_pending
    @count = 0
    date = (Time.now).strftime("%m")  
    add_id = params[:id] 
    loc_id = Location.find_by_address_id(add_id).id rescue nil
    requests = Request.where(:location_id => loc_id)
    resp = Response.where(:request_id => requests)
    respons = resp.where('extract(month from created_at) = ?', date)
    @counts = respons.pluck(:feedback) rescue nil
    @counts.each do |c|
      if c==nil
        @count = @count + 1
      end
    end
    render json: {count: @count}
  end
 
  #--
  ## Created By: Chtete
  ## Created On: 07/14/2017
  ## Purpose: For adding note for responses.
  #++
  def add_note_for_reviews
    ResponseNote.create(note_text: params[:review_note], response_id: params[:id], user_id: current_user.id)
    redirect_to home_index_path
    flash[:success] = "note added for review."
  end

  def add_note_for_google_reviews
    ResponseNote.create(note_text: params[:review_note],google_review_id: params[:id], user_id: current_user.id)   
    redirect_to home_index_path
  end
  
  def requests
    location_id = current_user.locations.ids rescue nil
    reviews = GoogleReview.where(location_id: location_id).count rescue nil 
    if current_user.has_role? :superadmin
      add_id = params[:id] 
      location_id = Location.find_by_address_id(add_id).id rescue nil
      @request = Request.where(:location_id => location_id)
      @review_id = @request.pluck(:review_user_id)
      @requests = ReviewUser.where(:id=>@review_id).all
      @address = Address.where(id: Location.pluck(:address_id))
      @add = @address.find_by(params[:location_id => location_id])

    elsif  current_user.has_role? :Client
      location_id = current_user.locations.first.id rescue nil
      @request = Request.where(:location_id => location_id)
      @review_id = @request.pluck(:review_user_id)
      @requests = ReviewUser.where(:id=>@review_id).all
      @address = Address.where(id: current_user.locations.pluck(:address_id))
      @add = @address.find_by(params[:location_id => location_id])
    else 
      @address = Address.where(id: current_user.client.locations.pluck(:address_id))
    end
    request_count_and_request_pending
    render :template => 'home/requests', :locals => {:reviews => reviews}
  end

  def review_history
    if current_user.has_role? :superadmin
      address_id =  params[:location_id]
      location_id = Location.find_by_address_id(address_id).id
      @request = Request.where(:location_id => location_id)
      @review_id = @request.pluck(:review_user_id)
      @requests = ReviewUser.where(:id=>@review_id)
      @user = User.where("client_id = ?", params[:client_id])
      @users_email = @user.find_by(params[:clients_id])
      @add = Address.find(address_id)
      req = Request.where(review_user: @requests )
    elsif current_user.has_role? :Client
      location_id = current_user.locations.find_by(address_id: params[:location_id]).id
      @request = Request.where(:location_id => location_id)
      @review_id = @request.pluck(:review_user_id)
      @requests = ReviewUser.where(:id=>@review_id).all
      @users_email = current_user
      @address = Address.where(id: current_user.locations.pluck(:address_id))
      @add = @address.find_by(id: params[:location_id])
      req = Request.where(review_user: @requests )
    else 
      @address = Address.where(id: current_user.client.locations.pluck(:address_id))
    end
      
    render json: {requests: @requests, email: @users_email.email, address: @add, req: req}
  end

  ##--
  ## Created By: NanRau
  ## Created On: 27/05/2017
  ## Purpose: To list location summary of review.
  #++
  def location_listing
    location_id = current_user.locations.ids rescue nil
    reviews = GoogleReview.where(location_id: location_id).count rescue nil
    # reviews = Response.where(:request_id => (Request.where(:location_id => location_id).ids)).all 
    if current_user.has_role? :superadmin
      @address = Address.where(id: Location.pluck(:address_id))
    elsif  current_user.has_role? :Client
      @address = Address.where(id: current_user.client.locations.pluck(:address_id))#Address.where(id: current_user.locations.pluck(:address_id))
    else 
      @address = Address.where(id: current_user.client.locations.pluck(:address_id))
    end
    request_count_and_request_pending
    render :template => 'home/location_listing', :locals => {:reviews => reviews}
  end

  ##--
  ## Created By: NanRau
  ## Created On: 27/05/2017
  ## Purpose: get method to add location.
  #++
  def add_address
    @clients = Client.select(:name,:id).where("name != ?", "superadmin")
  end
  
  ##--
  ## Created By: PiyPan
  ## Created On: 29/05/2017
  ## Purpose: To list users according to roles.
  #++
  def settings_user
    if current_user.has_role? :superadmin
      user = current_user.client.users.drop(1)
      user = current_user.client.users.search(params[:search]).order("created_at DESC") if params[:search]      
      if !user.present? && params[:search]
        search_role = Role.where('name LIKE :search', search: "%#{params[:search]}%").map(&:id)
        user = User.joins(:roles).where("role_id in (?)",search_role)
        unless user.present?
          user = user.drop(1)
          flash[:notice] = "There are no user containing the term(s) #{params[:search]}" if params[:search]
        end
      end  
    elsif current_user.has_role? :Client 
      user = current_user.client.users.drop(1)
      user = current_user.client.users.search(params[:search]).order("created_at DESC") if params[:search]
      if !user.present? && params[:search]
        search_role = Role.where('name LIKE :search', search: "%#{params[:search]}%").map(&:id)
        user = User.joins(:roles).where("role_id in (?)",search_role)
        unless user.present?
          user = current_user.client.users.drop(1)
          flash[:notice] = "There are no user containing the term(s) #{params[:search]}" if params[:search]
        end
      end  
    end
    request_count_and_request_pending
    location_id = current_user.locations.ids rescue nil
    @reviews = GoogleReview.where(location_id: location_id).count rescue nil
    render :template => 'home/settings_user', :locals => {:user => user} 
  end
  #--
  ## Created By: NanRau
  ## Created On: 24/08/2017
  ## Purpose: To add location by superadmin for client .
  #++

  def create_location
    if !current_user.nil?
      client = Client.find_by(id: params[:address][:location][:clients_id])
      Address.create(street: params[:address][:address_attributes][:street],zipcode:  params[:address][:address_attributes][:zipcode], city: params[:address][:address_attributes][:city], state: params[:address][:address_address_attributes_state], country: params[:address][:address_address_attributes_country])
      last_address = Address.last
      location = client.locations.create(clients_id: params[:address][:location][:clients_id],google_place_id: params[:address][:location][:google_place_id], location_phone_no: params[:address][:location][:location_phone_no],user_id: params[:address][:clients],google_location_id: params[:address][:location][:google_location_id]) rescue nil
      location.update(address_id: last_address.id)  rescue nil
      flash[:notice] = " Location added successfully."
      redirect_to home_index_path 
    end
  end
  def add_new_location
    @address = Address.new 
    @client = Client.select(:name,:id).where("name != ?", "superadmin")
    @location =  Location.new
  end
  

  def edit_location
    @address = Address.find_by(id: params[:id])
    @location = Location.find_by(address_id: params[:id])
    @client = Client.find_by(id: @location.clients_id)
    @user = User.find_by(id:  @location.user_id)
  end
  #--
  ## Created By: NanRau
  ## Created On: 24/08/2017
  ## Purpose: To update location by superadmin for client .
  #++
  def update_location
    @address = Address.find_by(id: params[:id])
    @address.update(street: params[:address][:address_attributes][:street],zipcode:  params[:address][:address_attributes][:zipcode], city: params[:address][:address_attributes][:city], state: params[:address][:address_address_attributes_state], country: params[:address][:address_address_attributes_country])
    @location = Location.find_by(address_id: params[:id])
    @location.update(clients_id: params[:address][:id],google_place_id: params[:address][:location][:google_place_id], location_phone_no: params[:address][:location][:location_phone_no],user_id: params[:address][:clients],google_location_id: params[:address][:location][:google_location_id])
    flash[:notice] = " Location has been updated successfully."
    redirect_to home_location_listing_path
 end

  ##--
  ## Created By: MayKan
  ## Created On: 05/07/2017
  ## Purpose: To list Clients in Superadmin's Settings tab.
  #++


  def settings_client
    if current_user.has_role? :superadmin
      client  = Client.all.select(:id, :name)
      user = User.joins(:roles).where("users_roles.role_id = ?", 2)
      user = user.search(params[:search]).order("created_at DESC") if params[:search]
      if !user.present? && params[:search]
        search_client = Client.where('name LIKE :search', search: "%#{params[:search]}%").map(&:id)
        user = User.joins(:roles).where("users_roles.role_id = ? and client_id in (?)",2, search_client)
      end
      unless user.present?
        user = User.joins(:roles).where("users_roles.role_id = ?", 2)
        flash[:notice] = "There are no user containing the term(s) #{params[:search]}" if params[:search]
      end 
    end
    request_count_and_request_pending
    location_id = current_user.locations.ids rescue nil
    @reviews = GoogleReview.where(location_id: location_id).count rescue nil
    render :template => 'home/settings_client', :locals => {:user => user} 
  end
  
  ##--
  ## Created By: PiyPan
  ## Created On: 07/06/2017
  ## Updated On: 27/06/2017
  ## Purpose: Subscription details for client
  #++

  def settings_subscription
    @clients =  Client.select(:name,:id).where("name != ?", "superadmin")
    subscription = Subscription.all 
    client = Client.all 
    location_id = current_user.locations.ids rescue nil
    reviews = GoogleReview.where(location_id: location_id).count rescue nil
    request_count_and_request_pending
    render :template => 'home/settings_subscription', :locals => {:reviews => reviews}
  end


  def subscriptions
    subscription = Subscription.find_by_client_id(params[:client_id])
    if subscription.nil?
      @subscription = Subscription.create(subscription_params)
      redirect_to home_settings_subscription_path, notice: t('.subscriptions')
    else 
      subscription.update(subscription_params)       
    end
  end
  
  def get_billing_client_date
    subscription = Subscription.find_by_client_id(params[:client_id])
    billing_date = subscription.next_billing_date rescue nil
    respond_with billing_date
  end

  def contact_sales
    location_id = current_user.locations.ids rescue nil
    @reviews = GoogleReview.where(location_id: location_id).count rescue nil
  end

  def contact_sale
    location_id = current_user.locations.ids rescue nil
    @reviews = GoogleReview.where(location_id: location_id).count rescue nil
    ApplicationMailer.contact_sales(params).deliver
    flash[:success] = "Your request sent successfully.We will communicate with you very soon."
    render 'contact_sales'
  end

   ##--
  ## Created By: NanRau
  ## Created On: 27/05/2017
  ## Purpose: send request to superadmin to add location.
  #++
  def send_request_add_location
    email = current_user.email
    ApplicationMailer.add_location_mail(email,params).deliver
    redirect_to home_index_path, notice: t('.request_sent_to_add_location')
  end


  ##--
  ## Created By: MayKan
  ## Created On: 27/06/2017
  ## Purpose: notification settings check box value.
  #++

  def notification_settings
    @notifications = NotificationType.all
  end

  def update_notification_settings
    email_push = params[:email_push]
    notification_type = params[:notification_type]
    check = params[:check]
    user_id = current_user.id
    notifications = NotificationSetting.where(users_id: user_id)
    @notify = notifications.find_by(notification_types_id: notification_type)
    
    if notification_type.present?
      if email_push == "email" 
        @notify.update_attributes(:email_notification_type => params[:check])
      else
        @notify.update_attributes(:push_notification_type => params[:check])
      end
    end
  end
  protected
    def address_params
    params[:address][:state]=params[:address][:address_address_attributes_state]
    params[:address][:country]=params[:address][:address_address_attributes_country]
    params.require(:address).permit( :client_id, :street, :city, :state, :country, :zipcode, client: [:clients_id, :google_place_id, :location_phone_no,:user_id,:google_location_id])
  end

  private 

  def subscription_params
    params.require(:subscriptions).permit(:next_billing_date, :client_id)
  end
end