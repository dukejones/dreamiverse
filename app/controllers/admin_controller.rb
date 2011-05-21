class AdminController < ApplicationController
  before_filter :require_user, :require_admin
  
  def admin
    filters ||= {}
    page_size = filters[:page_size] || 10
    page = filters[:page].to_i
    page = 1 if page <= 0
        
    @users = User.where(:username ^ 'feh')
    @users = @users.limit(page_size).offset(page_size * (page - 1))

    
    if request.xhr?
      users_html = ""
      @users.each { |user| users_html += render_to_string(:partial => 'users', :locals => {:user => user}) }
      render :json => {type: 'ok', html: users_html}
    end    
  end
  
  protected
  
  def require_admin
    unless current_user.auth_level == 5
      flash.alert = "This page requires admin access."
      redirect_to :root and return
    end
  end
end
