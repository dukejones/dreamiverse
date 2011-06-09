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
    
    # debugger
    # 1
    case order_by
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
    data,opts = {},{}
    title = params[:title] ||= ''
    data['title'] = title
    
    if title == 'last 7 days in users'
      opts['model'] = 'User'
      opts['title'] = title
      opts['lines'] = ['entries']
      opts['date_max_range'] = 7 
      opts['date_span'] = 'days'
     
      data = generate_line_chart_data(opts) 
      
    elsif title == 'last 8 weeks in users'
      opts['model'] = 'User'
      opts['title'] = title
      opts['lines'] = ['entries']
      opts['date_max_range'] = 8 
      opts['date_span'] = 'weeks'
      
      data = generate_line_chart_data(opts)
      
    elsif title == 'last 6 months in users'
      opts['model'] = 'User'     
      opts['title'] = title
      opts['lines'] = ['entries']
      opts['date_max_range'] = 6 
      opts['date_span'] = 'months'
      
      data = generate_line_chart_data(opts)
  
    elsif title == 'last 7 days in entries'
      opts['model'] = 'Entry'
      opts['title'] = title
      opts['lines'] = ['entries']
      opts['date_max_range'] = 7 
      opts['date_span'] = 'days'
      opts['date_format'] = '%a'
      
      data = generate_line_chart_data(opts)      
  
    elsif title == 'last 8 weeks in entries'
      opts['model'] = 'Entry'
      opts['title'] = title
      opts['lines'] = ['entries']
      opts['date_max_range'] = 8
      opts['date_span'] = 'weeks'
      
      data = generate_line_chart_data(opts)      
         
    elsif title == 'last 6 months in entries'
      opts['model'] = 'Entry'
      opts['title'] = title
      opts['lines'] = ['entries']
      opts['date_max_range'] = 6
      opts['date_span'] = 'months'
           
      data = generate_line_chart_data(opts)
        
    elsif title == 'last 6 months in comments'
      opts['title'] = title
      opts['lines'] = ['comments']
      opts['date_max_range'] = 6
      opts['date_span'] = 'months'
      opts['model'] = 'Comment'

      data = generate_line_chart_data(opts)
    
    elsif title == 'last 6 months in entry types'
      # opts['title'] = title
      # opts['lines'] = ['dream','vision','experience','article','journal']
      # opts['date_max_range'] = 5 # account for zeros
      # opts['date_span'] = 'months'
      # opts['model'] = 'Entry'
      # opts['conditions'] = "{:type => type}"
      # 
      # data = generate_line_chart_data(opts)      
     
      data['lines'] = ['dream','vision','experience','article','journal']
      data['date_max_range'] = 6 
    
      (0..data['date_max_range']).each do |num|
        vals = [] 
        label = Time.now - num.months
        label = label.strftime('%b %d')
      
        data['lines'].each_with_index do |type,i|
          vals[i] = Entry.where({:created_at => (num.months.ago.beginning_of_month)..(num.months.ago.end_of_month)} & {:type => type}).count
        end              
       data = append_line_chart_data(data,num,label,vals)  
      end  
    end   
        
    render :json => {type: 'ok', data: data} 
  end
     

  def generate_line_chart_data(opts)
    data = {}
    data['title'] = opts['title']
    data['lines'] = opts['lines']
    data['date_max_range'] = opts['date_max_range'] - 1 # account for zero's
    model = opts['model'].capitalize
    date_span = opts['date_span']
    date_format = opts['date_format'] ||= '%b %d'
    date_range_begin = "beginning_of_#{date_span.singularize}"
    date_range_end ="end_of_#{date_span.singularize}"

    (0..data['date_max_range']).each do |num|
      vals = []
      label = num.send(date_span).ago.strftime(date_format)
      # vals[0] = model.camelcase.constantize.where({:created_at => (num.send(date_span).ago.send(date_range_begin))..(num.send(date_span).ago.send(date_range_end))}).count  
      vals[0] = get_date_range_count(model,num,date_range_begin,date_range_end,date_span)  
      data = append_line_chart_data(data,num,label,vals)        
    end    
    return data
  end
  
  def get_date_range_count(model,num,range_begin,range_end,span)
    model.camelcase.constantize.where({:created_at => (num.send(span).ago.send(range_begin))..(num.send(span).ago.send(range_end))}).count
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
    @total_bedsheets = Image.scoped.where(section: 'Bedsheets').count
    
    entry_totals = []
    User.all.each_with_index do |u,i|
      entry_totals[i] = u.entries.count
      @average_entries_per_user = entry_totals.instance_eval { reduce(:+) / size.to_f }.round(2)
    end
    user_list
  end

  
  protected
  
  def require_admin
    unless current_user.auth_level >= User::AuthLevel[:admin]
      redirect_to :root, {alert: "This page requires admin access."} and return
    end
  end
end
