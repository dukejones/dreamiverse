class User::AuthenticationsController < ApplicationController
  def create
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.where(:provider => omniauth['provider'], :uid => omniauth['uid']).first
    if current_user
      if authentication
        # if the auth is already known, do nothing...
      else
        # if it's not known, create the auth & associate it with the current user.
        flash.notice = "successfully linked the #{omniauth['provider']} authorization to your account"
        current_user.apply_omniauth(omniauth).save!
      end
    else
      if authentication
        user = authentication.user
        set_current_user user
        flash.notice = "user #{user.username} logged in."
      else
        # user = User.create_from_omniauth(omniauth)
        # set_current_user user
        # flash.notice = "created new user: #{user.name}."

        # This should associate the new account with the newly authorized authorization.
        session[:registration_auth_provider] = omniauth['provider']
        username = omniauth['user_info']['nickname']
        email = omniauth['extra']['user_hash']['email']
        redirect_to join_path(user: {username: username, email: email}) and return
      end
    end
    redirect_to root_path
  end
end