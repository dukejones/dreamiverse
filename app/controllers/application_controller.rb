class ApplicationController < ActionController::Base
  helper_method :current_user
  protect_from_forgery

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def current_user=(user)
    session[:user_id] = user.id
    @current_user = user
  end
  # alias :current_user= :set_current_user

  def require_user
    unless current_user
      redirect_to :root and return
    end
  end
end
