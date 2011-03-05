class EntriesController < ApplicationController
  before_filter :require_user, :only => [:new, :edit, :stream]
  before_filter :query_username, :except => [:stream]

  def entry_list
    # This is an example of a hack due to tightly coupling Display to Data.
    session[:filters].delete(:type) if session[:filters]._?[:type] == "all entries"
    @entries = Entry.list(current_user, @user, session[:lens], session[:filters])
  end
  
  def index
    redirect_to(user_entries_path(@user.username)) unless params[:username]
    # debugger
    session[:lens] = :field
    session[:filters] = params[:filters]

    entry_list
    
    @user.starlight.add( 1 ) if unique_hit?

  end

  def show
    @entry = Entry.find params[:id]
    redirect_to(user_entry_path(@entry.user.username, @entry)) unless params[:username]

    entry_list
    i = @entries.index {|e| e == @entry } || 0
    @previous = @entries[i-1]
    @next = @entries[i+1] || @entries[0]
    # @entry = @entries[i]
    deny and return unless user_can_access?

    @comments = @entry.comments.order('created_at DESC') # .limit(10)
    @page_title = @entry.title
    
    if unique_hit?
      @entry.starlight.add( 1 )
      @entry.user.starlight.add( 1 )
    end
  end
  
  def new
    @entry = Entry.new
  end
  
  def edit
    @entry = Entry.find params[:id]
    deny and return unless user_can_write?
    render :new
  end

  def create
    whats = (params[:what_tags] || []).map {|word| What.for word }
    
    params[:entry][:dreamed_at] = parse_time(params[:dreamed_at])
    
    new_entry = current_user.entries.create!(params[:entry].merge(
      whats: whats
    ))
    redirect_to user_entry_path(current_user.username, new_entry)
  end
  
  def update
    params[:entry][:dreamed_at] = parse_time(params[:dreamed_at])

    @entry = Entry.find params[:id]
    deny and return unless user_can_write?

    @entry.set_whats(params[:what_tags])
    
    @entry.update_attributes( params[:entry] )
    redirect_to :action => :show, :id => params[:id]
  end
  
  def destroy
    @entry = Entry.find params[:id]
    deny and return unless user_can_write?
    
    @entry.destroy
    redirect_to user_entries_path(current_user.username)
  end

  def stream
    session[:lens] = :stream
    session[:filters] = params[:filters]

    @user = current_user
    
    entry_list
    
    if request.xhr?
      thumbs_html = ""
      @entries.each { |entry| thumbs_html += render_to_string(:partial => 'thumb_1d', :locals => {:entry => entry}) }
      render :json => {type: 'ok', html: thumbs_html}
    end
  end

  def bedsheet
    @entry = Entry.find(params[:id])
    @entry.view_preference.image = Image.find(params[:bedsheet_id])
    @entry.save!
    render :json => "entry bedsheet updated"
  rescue => e
    render :json => e.message, :status => :unprocessable_entity
  end

  protected

  def parse_time(time)
    # {"month"=>"10", "day"=>"26", "year"=>"2010", "hour"=>"8", "ampm"=>"am"}
    Time.zone.parse("#{time[:year]}-#{time[:month]}-#{time[:day]} #{time[:hour]}#{time[:ampm]}")
  end
  
  # sets @user to be either params[:username]'s user or current_user
  # Redirect to / if neither param nor current_user.
  def query_username
    @user = params[:username] ? User.find_by_username( params[:username] ) : current_user
    redirect_to root_path, :alert => "no user #{params[:username]}" and return unless @user
  end
  
  # requires @entry be set
  def user_can_access?
    @entry.everyone? || (current_user && current_user.can_access?(@entry))
  end

  # requires @entry be set
  def user_can_write?
    (current_user == @entry.user)
  end

  def deny
    if params[:username]
      redirect_to user_entries_path(params[:username]), :alert => "Access denied to this entry."
    else
      redirect_to :root, :alert => "Access denied to this entry."
    end
  end
    
end
