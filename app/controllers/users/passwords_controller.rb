class Users::PasswordsController < Devise::PasswordsController
  prepend_before_action :require_no_authentication       
  
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  #def create
  # super
  #end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    super
  end

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?
    if resource.errors.empty?
      redirect_to destroy_user_session_path
    else
      render 'edit'
      flash[:notice] = resource.errors.full_messages.to_sentence
    end
  end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  private
  def user_params
    params.require(:user).permit(:password, :reset_password_token, :password_confirmation)
  end
end
