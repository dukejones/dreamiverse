class User::RegistrationsController < ApplicationController
  layout 'home'

  def new
    redirect_to :root and return if current_user
    
    @user = User.new(params[:user])
    
    render "users/join"
  end

  def forgot_password
    redirect_to :root and return if current_user
    
    render "users/forgot_password"
  end


  
  def create
    # creates a user with an email / password.
    params[:user][:seed_code] = session[:seed_code] unless params[:user].has_key?(:seed_code)

    redirect_to join_path(user: params[:user]), :alert => "captcha was invalid" and return unless verify_recaptcha
    
    @user = User.create(params[:user])
    if @user.valid?
      set_current_user @user
      
      if auth_provider = session.delete(:registration_auth_provider)
        redirect_to "/auth/#{auth_provider}"
      else
        redirect_to :root
      end
    else
      flash[:user_registration_errors] = @user.errors
      redirect_to :root, :alert => "Could not create the user"
    end
  end
  
  def update
    # adds email / password to existing user.    
  end
end