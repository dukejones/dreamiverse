class AdminController < ApplicationController
  before_filter :require_user, :require_admin

  def user_list
    # params ||= {}
    # params = {} if !params?
    page_size = params[:page_size] || 40
    page = params[:page].to_i
    page = 1 if page <= 0   
    
    # debugger
    # 1

    @users = User.where(:username ^ 'feh')
    @users = @users.limit(page_size).offset(page_size * (page - 1))
    @page_size = page_size
    @total_pages = (@users.count / page_size)
    @total_pages = @total_pages.ceil + 1
    
    if request.xhr?
      users_html = ""
      @users.each { |user| users_html += render_to_string(:partial => 'users', :locals => {:user => user}) }
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
    unless current_user.auth_level == 5
      flash.alert = "This page requires admin access."
      redirect_to :root and return
    end
  end
end
