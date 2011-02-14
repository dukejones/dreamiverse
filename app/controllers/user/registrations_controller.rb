class User::RegistrationsController < ApplicationController
  
  def create
    # creates a user with an email / password.
    params[:user][:seed_code] = session[:seed_code] unless params[:user].has_key?(:seed_code)
    
    if user = User.create(params[:user])
      set_current_user user
    end

    redirect_to :root
  end
  
  def update
    # adds email / password to existing user.    
  end
end