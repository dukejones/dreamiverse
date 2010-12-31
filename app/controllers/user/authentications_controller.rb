class User::AuthenticationsController
  def create
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.where(:provider => omniauth['provider'], :uid => omniauth['uid']).first
    if current_user
      if authentication
        # if the auth is already known, do nothing...
      else
        # if it's not known, create the auth & associate it with the current user.
        flash.notice = "user already logged in. associating the new authorization."
        current_user.apply_omniauth(omniauth).save!
      end
    else
      if authentication
        set_current_user authentication.user
        flash.notice = "user #{user.name} logged in."
      else
        user = User.create_from_omniauth(omniauth)
        set_current_user user
        flash.notice = "created new user: #{user.name}."
      end
    end
    
    redirect_to root_path
  end
end