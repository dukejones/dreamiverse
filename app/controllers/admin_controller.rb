class AdminController < ApplicationController
  before_filter :require_user, :require_admin

  def user_list
    @filters = session[:admin_filters] = params[:filters] || {}
    @page_size = @filters[:page_size] || 40
    @page = @filters[:page].to_i 
    @page = 1 if @page < 1
    @order_by = @filters[:order_by].blank? ? 'created_at' : @filters[:order_by] 
    @direction = 'DESC' 
    @direction = 'ASC' if @order_by == 'username'

    case @order_by
      when 'traffic' then @users = User.includes(:entries).order("sum(entries.uniques) #{@direction}").group('users.id')
      when 'entries' then @users = User.includes(:entries).order("count(entries.id) #{@direction}").group('users.id')
      else
        @users = User.scoped.order("#{@order_by} #{@direction}") 
      end
         
    @users = @users.limit(@page_size).offset(@page_size * (@page - 1))
        
    if request.xhr?
      users_html = ""
      @users.each { |user| users_html += render_to_string(partial: 'user', object: user) }
      render :json => {type: 'ok', html: users_html}
    end          
  end

  def charts
    title = params[:title] || 'none'
    data = {}
    if title == 'last_7_days_in_users'
      (0..6).each do |num|
        t = Time.now - num.days
        newUsers = User.where(:created_at => (num.days.ago.beginning_of_day)..(num.days.ago.end_of_day)).count
        data[num] = ({
          label: {pos: num, bar: num, val: t.strftime("%a %d")},
          data: {pos: num, bar: (num + 1), val: newUsers}
        })
        
        data['total'] = num
      end  
      # data = data.invert   
      # data.map {|k,v| [k, v.sort.reverse]}
    end
    
    if request.xhr?
      render :json => {type: 'ok', data: data}
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
