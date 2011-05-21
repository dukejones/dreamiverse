class AdminController < ApplicationController
  before_filter :require_user, :require_admin

  def user_list
    params ||= {}
    page_size = params[:page_size] || 3
    page = params[:page].to_i
    page = 1 if page <= 0   
    
    # debugger
    # 1

    @users = User.where(:username ^ 'feh')
    @users = @users.limit(page_size).offset(page_size * (page - 1))
    
    if request.xhr?
      users_html = ""
      @users.each { |user| users_html += render_to_string(:partial => 'users', :locals => {:user => user}) }
      render :json => {type: 'ok', html: users_html}
    end    
       
  end
     
  def admin
   user_list
  end


  
  protected
  
  def require_admin
    unless current_user.auth_level == 5
      flash.alert = "This page requires admin access."
      redirect_to :root and return
    end
  end
end
