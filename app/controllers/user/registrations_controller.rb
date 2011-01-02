class User::RegistrationsController < ApplicationController
  
  def create
    # or creates a user with an email / password.
    if user = User.create(params[:user])
      set_current_user user
    end

    redirect_to :root
  end
  
  def update
    # adds email / password to existing user.    
  end
end