class ApplicationController < ActionController::Base
  helper_method :current_user
  protect_from_forgery

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def add_starlight(entity)
    if unique_hit?
      Starlight.add(5, entity)
    end
  end
  
  def unique_hit?
    Hit.unique? request.fullpath, request.remote_ip, current_user
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
