class ApplicationController < ActionController::Base
  helper_method :current_user
  protect_from_forgery

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

protected
  def set_current_user(user)
    session[:user_id] = user ? user.id : nil
    @current_user = user
  end

  def require_user
    unless current_user
      redirect_to :root and return
    end
  end
end
