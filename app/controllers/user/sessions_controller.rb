class User::SessionsController < ApplicationController
  layout 'home'

  def new
    redirect_to :root and return if current_user
    
    render "users/login"
  end

  def create
    if user = User.authenticate(params[:user])
      set_current_user user
      if params[:remember_me]
        cookies[:dreamcatcher_remember_me] = { value: user.remember_me_cookie_value, expires: 2.weeks.from_now }
      end
      flash.notice = 'logged in.'
    else
      flash.alert = "unrecognized username / password"
      redirect_to login_path and return
    end
    
    if auth_provider = session.delete(:registration_auth_provider)
      redirect_to "/auth/#{auth_provider}"
    elsif request.path == root_path || request.path == login_path || request.env['HTTP_REFERER'].blank?
      redirect_to root_path
    else
      redirect_to :back
    end
  end

  def destroy
    set_current_user(nil)
    cookies.delete :dreamcatcher_remember_me
    redirect_to :root
  end
end

