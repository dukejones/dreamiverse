class User::RegistrationsController < ApplicationController
  
  def create
    # creates a user with an email / password.
    params[:user][:seed_code] = session[:seed_code] unless params[:user].has_key?(:seed_code)
    
    # TODO: must detect duplicate users!
    @user = User.create(params[:user])
    if @user.valid?
      set_current_user @user
      redirect_to :root
    else
      flash[:user_registration_errors] = @user.errors
      redirect_to :root, :alert => "Could not create the user"
    end
  end
  
  def update
    # adds email / password to existing user.    
  end
end