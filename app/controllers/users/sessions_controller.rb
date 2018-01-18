class Users::SessionsController < Devise::SessionsController
  skip_before_action :require_no_authentication, :only => [ :new, :create, :cancel ]
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, :only => [:index, :update_user_profile, :add_address]

  # GET /resource/sign_in
  def new
    super
  end

  def index
  end
  
  # POST /resource/sign_in
  def create
    begin
      @user =  User.find_by(email: params[:user][:email])
      if @user.valid_password? params[:user][:password] and @user.active?
        @user =  sign_in("user", User.find_by(email: params[:user][:email]))
        redirect_to home_index_path
      elsif !@user.active? and @user.valid_password? params[:user][:password]
        flash[:error] = "Sorry, this account has been deactivated please contact to superadmin"
        redirect_to root_path
      else
        flash[:error] = "Invalid email or password."
        redirect_to root_path
      end
    rescue Exception => e
      flash[:error] = "Invalid email or password."
      redirect_to root_path
    end
  end
   
  ##--
  ## Created By: NanRau
  ## Created On: 30/05/2017
  ## Purpose: To update the admin profile.
  #++

  def update_user_profile
    current_user.update(email: params[:user][:email])
    current_user.client.update(client_params_attr)
    redirect_to home_admin_profile_path, notice: t('.update_user_profile') 
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  ##--
  ## Created By: NanRau
  ## Created On: 27/05/2017
  ## Purpose: To add location by superadmin for client .
  #++

  def add_address
    if !current_user.nil?
      client = Client.find_by(id: params[:address][:id])
      Address.create(address_params)
      last_address = Address.last
      location = client.locations.create(clients_id: params[:address][:id],google_place_id: params[:address][:google_place_id], location_phone_no: params[:address][:location_phone_no],user_id: params[:address][:client],google_location_id: params[:address][:google_location_id]) rescue nil
      location.update(address_id: last_address.id)  rescue nil
      redirect_to home_index_path, notice: t('.add_address') 
    end
  end

  def create_template
  end

  protected
  def client_params_attr
    params.require(:user).permit(:send_request_email, :send_request_mobile_no)
  end
  def address_params
    params[:address][:state]=params[:address][:address_state]
    params[:address][:country]=params[:address][:address_country]
    params.require(:address).permit( :client_id, :street, :city, :state, :country, :zipcode, location: [:clients_id, :google_place_id, :location_phone_no,:user_id,:google_location_id])
  end
end



