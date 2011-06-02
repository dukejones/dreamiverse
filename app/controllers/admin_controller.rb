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

  def load_line_chart
    title = params[:title] || 'none'
    data = {}
    data['title'] = title
    
    if title == 'last 7 days in users'
      data['lines'] = ['users']
      data['max_range'] = 5 # account for zeros
            
      (0..6).each do |num|
        vals = []
        label = Time.now - num.days
        label = label.strftime('%a')
        vals[0] = User.where(:created_at => (num.days.ago.beginning_of_day)..(num.days.ago.end_of_day)).count
        data = append_line_chart_data(data,num,label,vals)
      end
      
    elsif title == 'last 8 weeks in users'
      data['lines'] = ['users']
      data['max_range'] = 5 # account for zeros      
      
      (0..7).each do |num|
        vals = []
        label = Time.now - num.weeks
        label = label.strftime('%b %d')
        vals[0] = User.where(:created_at => (num.weeks.ago.beginning_of_week)..(num.weeks.ago.end_of_week)).count
        data = append_line_chart_data(data,num,label,vals)
      end
      
    elsif title == 'last 6 months in users'
      data['lines'] = ['users']
      data['max_range'] = 5 # account for zeros
          
      (0..5).each do |num|
        vals = []
        label = Time.now - num.months
        label = label.strftime('%b %d')
        vals[0] = User.where(:created_at => (num.months.ago.beginning_of_month)..(num.months.ago.end_of_month)).count
        data = append_line_chart_data(data,num,label,vals)        
      end

    elsif title == 'last 7 days in entries'
      data['lines'] = ['entries']
      data['max_range'] = 5 # account for zeros
      
      (0..6).each do |num|
        vals = []
        label = Time.now - num.days
        label = label.strftime('%a')
        vals[0] = Entry.where(:created_at => (num.days.ago.beginning_of_day)..(num.days.ago.end_of_day)).count
        data = append_line_chart_data(data,num,label,vals)
      end

    elsif title == 'last 8 weeks in entries'
      data['lines'] = ['entries']
      data['max_range'] = 5 # account for zeros
      
      (0..7).each do |num|
        vals = []
        label = Time.now - num.weeks
        label = label.strftime('%b %d')
        vals[0] = User.where(:created_at => (num.weeks.ago.beginning_of_week)..(num.weeks.ago.end_of_week)).count
        data = append_line_chart_data(data,num,label,vals)
      end
         
    elsif title == 'last 6 months in entries'
      data['lines'] = ['entries']
      data['max_range'] = 5 # account for zeros
      
      (0..5).each do |num|   
        vals = [] 
        label = Time.now - num.months
        label = label.strftime('%b %d')
              
        vals[0] = Entry.where(:created_at => (num.months.ago.beginning_of_month)..(num.months.ago.end_of_month)).count
        data = append_line_chart_data(data,num,label,vals)        
      end

    elsif title == 'last 6 months in entry types' 
      data['lines'] = ['dream','vision','experience','article','journal']
      data['max_range'] = 5 # account for zeros
      
      (0..data['max_range']).each do |num|
        vals = [] 
        label = Time.now - num.months
        label = label.strftime('%b %d')
        
        data['lines'].each_with_index do |type,i|
          vals[i] = Entry.where({:created_at => (num.months.ago.beginning_of_month)..(num.months.ago.end_of_month)} & {:type => type}).count
        end       
        data = append_line_chart_data(data,num,label,vals)    
      end  
    end  
  
    if request.xhr?
      render :json => {type: 'ok', data: data}
    end            
  end


  def load_pie_chart 
    data = {}
    title = params[:title]
    data['title'] = title
      
    if title == 'seed codes usages'
      data['slices'] = User.scoped.where(:seed_code ^ nil).group(:seed_code).map(&:seed_code)  
       
      (0..data['slices'].count).each do |num|        
        label = data['slices'][num]
        val = User.scoped.where(seed_code: data['slices'][num]).count
        data = append_pie_chart_data(data,num,label,val)
      end
      
    elsif title == 'top 32 users by entries'
      data['slices'] = User.includes(:entries).order("sum(entries.uniques) DESC").group('users.id').limit(32).map(&:username)
      (0..data['slices'].count).each do |num|        
        label = data['slices'][num]
        user = User.find_by_username(data['slices'][num])
        val = user.nil? ? '' : user.entries.count
        data = append_pie_chart_data(data,num,label,val)
      end  

    elsif title == 'top 32 users by starlight'
      data['slices'] = User.includes(:entries).order("sum(entries.uniques) DESC").group('users.id').limit(32).map(&:username)
      (0..data['slices'].count).each do |num|        
        label = data['slices'][num]
        user = User.find_by_username(data['slices'][num])
        val = user.nil? ? '' : user.starlight
        data = append_pie_chart_data(data,num,label,val)
      end        
        
    elsif title == 'top 32 tags'
      data['slices'] = Tag.scoped.order("count(noun_id) DESC").group(:noun_id).limit(32).map(&:noun_id)
      (0..data['slices'].count).each do |num| 
        #log "data[slices][num]: #{data['slices'][num]}" 
        what = What.find_by_id(data['slices'][num])
        label = what.nil? ? '' : what.name
       
        # user = User.find_by_username(data['slices'][num])
        # tags.each do |t| count = Tag.where(:noun_id => t.noun_id).count; pp count end
        val = Tag.where(:noun_id => data['slices'][num]).count
        data = append_pie_chart_data(data,num,label,val)
      end                 
    end

    if request.xhr?
      render :json => {type: 'ok', data: data}
    end        
  end


  def load_bedsheets
    @data = {}
    top_bedsheet_ids = ViewPreference.scoped.where(:image_id ^ nil).order("count(image_id) DESC").group(:image_id).limit(32).map(&:image_id)
    
    num = 0
    nodes_html = ''
    top_bedsheet_ids.each do |bedsheet_id|  

      image = Image.find_by_id(bedsheet_id)
      unless image.nil?
        @data['id'] = image.id
        @data['filename'] = image.original_filename
        @data['user_count'] = ViewPreference.scoped.where({image_id: image.id} & {viewable_type: 'User'}).count
        @data['entry_count'] = ViewPreference.scoped.where({image_id: image.id} & {viewable_type: 'Entry'}).count

        nodes_html += render_to_string(partial: 'bedsheet_node')
      end
      num += 1
    end
    
    if request.xhr?
      render :json => {type: 'ok', html: nodes_html}
    end      
  end
     
  # params = data hash, index, value, label, value
  def append_line_chart_data(data,i,label,vals)
    data[i] = ({
      label: label,
      vals: vals
    })     
    data
  end

  # params = data hash, index, value, label, value
  def append_pie_chart_data(data,i,label,val)
    data[i] = ({
      label: label,
      val: val
    })     
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
