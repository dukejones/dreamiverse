class User::SessionsController < ApplicationController
  def new
    flash.keep
    redirect_to root_path
  end

  def create
    omniauth = request.env["omniauth.auth"] # pull omniauth from the depths of Rack
    auth = Authentication.where(:provider => omniauth['provider'], :uid => omniauth['uid']).first
    if current_user
      # there's a user. 
      # if the auth is already known, do nothing...
      # if it's not known, create the auth & associate it with the current user.
      flash.notice = "User already logged in. Associating the new authorization."
    else
      if auth
        user = auth.user
        flash.notice = "User logged in: #{user.username}"
      else
        user = User.create_with_omniauth(omniauth)
        flash.notice = "Created new user #{user.name}"
      end
      current_user = user
    end
    
    redirect_to root_path
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end

