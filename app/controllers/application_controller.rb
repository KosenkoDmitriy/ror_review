class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  protect_from_forgery with: :null_session

  def states
    country = CS.countries.select{|key, value| key[params[:country]]}.first.first
    render json: CS.states(country).collect{|code, state| [state,code] }.to_json
  end

  def cities
    country = CS.countries.select{|key, value| key[params[:country]]}.first.first
    state = CS.states(country).select{|key, value| key[params[:state]]}.first.first
    render json: CS.cities(state, country).to_json
  end
 
  
  ##--
  ## Created By: NikG
  ## Created On: 04/08/2017
  ## Purpose: changing countrywise code as per selected country for client and superadmin.
  #++

  def change_country_code
    @country_mob_code = ISO3166::Country[params[:country_code]].country_code
    render json: {country_code_mob: @country_mob_code}
  end


  ##--
  ## Created By: ChTete
  ## Created On: 21/06/2017
  ## Purpose: show locations based on client drop down only for superadmin.
  #++
  def client_location
    client_id = params[:client_id]
    users_id = User.find_by(client_id: client_id).id
    locations = Location.where(user_id: users_id)
    address_ids = locations.all.collect {|p| p.address_id}
    address = Address.all.where(:id => address_ids)
    #for showing reviews on index and reviews page for first location of selected client. 
    first_location = locations.first.id rescue nil
    google_reviews = GoogleReview.where(location_id: first_location).order('google_review_update_time DESC') rescue nil
    responses = Response.where(:request_id => (Request.where(:location_id => first_location))) rescue nil 
    # for request count
    date_previous = (Time.now - 1.month).strftime("%m") 
    requests1 = Request.where(:location_id=> first_location) rescue nil
    request_count = requests1.where('extract(month from send_at) = ?', date_previous).count rescue nil 
    @response_month_name = {}
    response = responses.all.group('extract(month from created_at)').count
    response.each do |month_no, count|
      month_name = Date::MONTHNAMES[month_no]
      @response_month_name[month_name] = count
    end
    response_notes = ResponseNote.all.order("created_at DESC")
    client_response = ClientResponse.all.order("created_at DESC")
    isclient = current_user.has_role?(:Client)
    render json: {chart_data: @response_month_name, addresses: address,responses: responses, google_reviews: google_reviews, request_count: request_count, isclient: isclient, client_response: client_response, response_notes: response_notes}
  end
  ##--
  ## Created By: NanRau
  ## Created On: 20/06/2017
  ## Purpose: get all the client's users in dropdown on add location by superdmin page
  #++
  def client_users
    client_id = params[:client_id]
    client = Client.find_by(id: params[:client_id])
    user_ids = client.users.collect{|p| p.client_id}
    clients_users = User.all.where(:client_id => user_ids)
    render json: {user: clients_users}
  end
end
