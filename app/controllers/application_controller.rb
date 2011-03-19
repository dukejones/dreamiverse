class ApplicationController < ActionController::Base
  before_filter :set_seed_code, :set_client_timezone
  helper_method :current_user, :page_is_mine?, :is_mobile?
  protect_from_forgery

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def page_is_mine?
    (current_user && (params[:username] == current_user._?.username)) ||
    request.path == stream_path ||
    request.path == '/entries' ||       # there's got to be a better way.
    request.path =~ /\/entries\/\d+\/edit/ ||
    request.path == '/entries/new'
  end
  
  def unique_hit?
    Hit.unique? request.fullpath, request.remote_ip, current_user
  end
  
  def hit(starlit_entity)
    starlit_entity.hit! if unique_hit?
  end

  MOBILE_BROWSERS = ["android", "ipod", "opera mini", "blackberry", "palm","hiptop","avantgo","plucker", "xiino","blazer","elaine", "windows ce; ppc;", "windows ce; smartphone;","windows ce; iemobile", "up.browser","up.link","mmp","symbian","smartphone", "midp","wap","vodafone","o2","pocket","kindle", "mobile","pda","psp","treo", "ipad"]
  def is_mobile?
    agent = request.user_agent.downcase
    MOBILE_BROWSERS.each do |m|
      return true if agent.match(m)
    end
    return false
  end

  protected

  def set_client_timezone
    min = cookies[:timezone].to_i
    Time.zone = ActiveSupport::TimeZone[-min.minutes]  
  end

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
    session[:seed_code] = params[:s] if params[:s]
    session[:seed_code] ||= params[:username] if params[:username]
  end
end
