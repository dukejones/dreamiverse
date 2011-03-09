class ApplicationController < ActionController::Base
  before_filter :set_seed_code
  helper_method :current_user, :add_starlight, :page_is_mine?
  protect_from_forgery

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def page_is_mine?
    (current_user && (params[:username] == current_user._?.username)) ||
    request.path == stream_path ||
    request.path =~ entries_path
  end
  
  # TODO: deprecate
  def add_starlight(entity, amt)
    Starlight.add(entity, amt)
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
  
  def render_404
    render :file => "#{Rails.public_path}/404.html",  :status => 404
  end

  def set_seed_code
    return if request.xhr?
    session[:seed_code] = params[:seed] if params[:seed]
    session[:seed_code] ||= params[:username] if params[:username]
  end
end
