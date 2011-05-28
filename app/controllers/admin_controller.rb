class AdminController < ApplicationController
  before_filter :require_user, :require_admin

  def user_list
    @filters = session[:admin_filters] = params[:filters] || {}
    @page_size = @filters[:page_size] || 40
    @page = @filters[:page].to_i 
    @page = 1 if @page < 1
    order_by = @filters[:order_by].blank? ? 'created_at' : @filters[:order_by] 
    direction = 'DESC' 
    direction = 'ASC' if @order_by == 'username'

    case @order_by
      when 'traffic' then @users = User.includes(:entries).order("sum(entries.uniques) #{direction}").group('users.id')
      when 'entries' then @users = User.includes(:entries).order("count(entries.id) #{direction}").group('users.id')
      else
        @users = User.scoped.order("#{order_by} #{direction}") 
      end
         
    @users = @users.limit(@page_size).offset(@page_size * (@page - 1))
        
    if request.xhr?
      users_html = ""
      @users.each { |user| users_html += render_to_string(partial: 'user', object: user) }
      render :json => {type: 'ok', html: users_html}
    end          
  end

  def charts
    scope = params[:scope] || 'none'
    data = {}
    
    if scope == 'last_7_days_in_users'
      (0..6).each do |num|
        label = Time.now - num.days
        label_format = '%a'
        val = User.where(:created_at => (num.days.ago.beginning_of_day)..(num.days.ago.end_of_day)).count
        data = append_data(data,num,label,label_format,val)
      end
      
    elsif scope == 'last_8_weeks_in_users'
      (0..7).each do |num|
        label = Time.now - num.weeks
        label_format = '%b %d'
        val = User.where(:created_at => (num.weeks.ago.beginning_of_week)..(num.weeks.ago.end_of_week)).count
        data = append_data(data,num,label,label_format,val)
      end
      
    elsif scope == 'last_6_months_in_users'
      (0..5).each do |num|
        label = Time.now - num.months
        label_format = '%b %d'
        val = User.where(:created_at => (num.months.ago.beginning_of_month)..(num.months.ago.end_of_month)).count
        data = append_data(data,num,label,label_format,val)        
      end

    elsif scope == 'last_7_days_in_entries'
      (0..6).each do |num|
        label = Time.now - num.days
        label_format = '%a'
        val = Entry.where(:created_at => (num.days.ago.beginning_of_day)..(num.days.ago.end_of_day)).count
        data = append_data(data,num,label,label_format,val)
      end

    elsif scope == 'last_8_weeks_in_entries'
      (0..7).each do |num|
        label = Time.now - num.weeks
        label_format = '%b %d'
        val = User.where(:created_at => (num.weeks.ago.beginning_of_week)..(num.weeks.ago.end_of_week)).count
        data = append_data(data,num,label,label_format,val)
      end
      
    elsif scope == 'last_6_months_in_entries'
      (0..5).each do |num|
        label = Time.now - num.months
        label_format = '%b %d'
        val = Entry.where(:created_at => (num.months.ago.beginning_of_month)..(num.months.ago.end_of_month)).count
        data = append_chart_data(data,num,label,label_format,val)        
      end      
    end
   
    if request.xhr?
      render :json => {type: 'ok', data: data}
    end          
  end
  
  # params = data hash, index, value
  def append_chart_data(data,i,label,label_format,val)
    data[i] = ({
      label: {pos: i, bar: i, val: label.strftime(label_format)},
      data: {pos: i, bar: (i + 1), val: val}
    })     
    data['total'] = i
    data
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
