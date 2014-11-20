class ApplicationController < ActionController::Base
  before_filter :set_seed_code, :set_client_timezone
  helper_method :current_user, :page_is_mine?, :is_mobile?
  protect_from_forgery with: :exception

  def current_user
    if session[:user_id] 
      @current_user ||= User.find(session[:user_id]) 
    elsif cookies[:dreamcatcher_remember_me]
      @current_user ||= User.authenticate_from_remember_me_cookie(cookies[:dreamcatcher_remember_me])
    end
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
    return false unless request.user_agent
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
    # cookies.permanent.signed[:dreamcatcher_remember_me] = [user.id, user.salt] unless user.nil?
    @current_user = user
  end

  def require_user
    unless current_user
      redirect_to :root, {alert: 'You must be logged in to see this page.'} and return
    end
  end
  def require_moderator
    unless current_user && current_user.auth_level >= User::AuthLevel[:moderator]
      redirect_to :root, {alert: 'You must be a Dreamcatcher moderator to access this page.'} and return
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
