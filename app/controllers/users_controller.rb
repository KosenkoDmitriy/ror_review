class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_user, only: [:destroy]

  ##--
  ## Created By: PiyPan
  ## Created On: 24/05/2017
  ## Purpose: To add clients and users.
  #++
  
  def new
    @user = User.new
    if current_user.has_role? :superadmin
      @users=User.select(:first_name,:id).where(:client_id=>current_user.client_id)
      @users=@users.where('id != ?', current_user.id)
    end
  end

  def index
    @users = User.all
  end

  def create
    if User.where(:email => params[:user][:email]).exists?
      flash[:error] = "Email already exist"
    elsif current_user.has_role? :superadmin 
      @address = Address.create(user_params[:address])
      @client = Client.create(name: params[:user][:clients][:name],website: params[:user][:clients][:website], originator: params[:user][:clients][:originator] )
      add = Address.last
      @client.update(address_id: add.id)
      @user = @client.users.create(first_name: user_params[:first_name], last_name: user_params[:last_name], email: user_params[:email], password: user_params[:password], password_confirmation: user_params[:password_confirmation], primary_mobile_no: params[:country_code_mob] + user_params[:primary_mobile_no])
      @subscription = @client.subscriptions.create(next_billing_date: params[:user][:subscriptions][:next_billing_date])
      ApplicationMailer.user_created(@user).deliver
      @user.add_role(params[:roles_name])
      NotificationType.all.each do |t| 
        NotificationSetting.create(users_id: @user.id, notification_types_id: t.id)
      end
      authorize! :create, @user     
      flash[:notice] = "Client is successfully created."
    elsif current_user.has_role? :Client
      @user = current_user.client.users.create(user_params)
      @user.update(primary_mobile_no: params[:country_code_mob] + user_params[:primary_mobile_no])
      @user.add_role(params[:roles_name])
      NotificationType.all.each do |t| 
        NotificationSetting.create(users_id: @user.id, notification_types_id: t.id)
      end
      authorize! :create, @user
      flash[:notice] = "User is successfully created."
    else
      render 'new'
    end
    redirect_to new_user_path
  end

  def edit
    @user = User.find(params[:id])
    @client = @user.client
    @address = @client.address
  end

  def update
    @user = User.find(params[:id])
    if current_user.has_role? :superadmin
      if params[:user][:password].blank? 
        @user.update_without_password(first_name: user_params[:first_name], last_name: user_params[:last_name], email: user_params[:email], password: user_params[:password], password_confirmation: user_params[:password_confirmation], primary_mobile_no: user_params[:primary_mobile_no])
        @user_deactivate=User.where(:client_id => @user.client_id)
        @user_deactivate.each do|user_deactivate|
          user_deactivate.update_attributes(:active=>user_params[:active])
          user_deactivate.save(:validate => false)
        end
      else
        @user.update(first_name: user_params[:first_name], last_name: user_params[:last_name], email: user_params[:email], password: user_params[:password], password_confirmation: user_params[:password_confirmation], primary_mobile_no: user_params[:primary_mobile_no])
      end
      @user.client.update(name: params[:user][:clients][:name],website: params[:user][:clients][:website], originator: params[:user][:clients][:originator])
      @user.client.address.update(street: params[:user][:address][:street],city: params[:user][:address][:city],state: params[:user][:address][:state],country: params[:user][:address][:country],zipcode: params[:user][:address][:zipcode] )
      authorize! :update, @user
    
    elsif current_user.has_role? :Client
      if params[:user][:password].blank? 
        @user.update_without_password(user_params)
      else
        @user.update(user_params)
      end
      @user.roles.update(name: params[:roles_name])
      authorize! :update, @user
    else
      render 'edit'
    end
    redirect_to home_settings_user_path
  end

  def destroy
    if current_user.has_role? :superadmin
      @user.destroy
      redirect_to root_path
    end
  end

  ##--
  ## Created By: MayKan
  ## Created On: 07/07/2017
  ## Purpose: To add users of superadmin.
  #++

  def new_super_user
    @user = User.new 
  end

  ##--
  ## Created By: MayKan
  ## Created On: 07/07/2017
  ## Purpose: To add users of superadmin.
  #++

  def create_super_user
    if User.where(:email => params[:user][:email]).exists?
      flash[:error] = "Email already exist"    
    elsif current_user.has_role? :superadmin 
      @user = current_user.client.users.create(user_params)
      @user.update(primary_mobile_no: params[:country_code_mob] + user_params[:primary_mobile_no])
      @user.add_role(params[:roles_name])
      NotificationType.all.each do |t| 
        NotificationSetting.create(users_id: @user.id, notification_types_id: t.id)
      end
      authorize! :create, @user
      flash[:notice] = "User is successfully created."
    else
      render 'new_super_user'
    end
    redirect_to new_super_user_path
  end

  ##--
  ## Created By: MayKan
  ## Created On: 07/07/2017
  ## Purpose: To add users of superadmin.
  #++

  def edit_super_user
    @user = User.find(params[:id])
  end

  ##--
  ## Created By: MayKan
  ## Created On: 07/07/2017
  ## Purpose: To add users of superadmin.
  #++

  def update_super_user
    @user = User.find(params[:id])
    if current_user.has_role? :superadmin 
      if params[:user][:password].blank? 
        @user.update_without_password(user_params)
      else
        @user.update(user_params)
      end
      @user.roles.update(name: params[:roles_name])
      authorize! :update, @user
    else
      render 'edit_super_user'
    end
      redirect_to home_settings_user_path
  end

  private

  def user_params
    params.require(:user).permit(:active,:first_name, :last_name, :client_id, :email, :password, :password_confirmation, :primary_mobile_no, client: [:name, :website, :originator], address: [:street, :city, :state, :country, :zipcode], subscription: [:next_billing_date, :client_id])
  end

  def find_user
    @user = User.find(params[:id])
  end
end