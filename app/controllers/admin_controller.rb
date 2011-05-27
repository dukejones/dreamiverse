class AdminController < ApplicationController
  before_filter :require_user, :require_admin

  def user_list
    page_size = params[:page_size] || 40
    page = params[:page].to_i
    page = 1 if page <= 0   
    
    @users = User.scoped
    @users = @users.limit(page_size).offset(page_size * (page - 1))
    @page_size = page_size
    
    if request.xhr?
      users_html = ""
      @users.each { |user| users_html += render_to_string(partial: 'user', object: user) }
      render :json => {type: 'ok', html: users_html}
    end    
       
  end
     
  def admin
    @users_created_last_week = User.where(:created_at.gt => 1.week.ago).count
    @users_created_last_month = User.where(:created_at.gt => 1.month.ago).count
    @entries_created_last_week = Entry.where(:created_at.gt => 1.week.ago).count
    @entries_created_last_month = Entry.where(:created_at.gt => 1.month.ago).count
    user_list
  end


  
  protected
  
  def require_admin
    unless current_user.auth_level >= User::AuthLevel[:admin]
      redirect_to :root, {alert: "This page requires admin access."} and return
    end
  end
end
