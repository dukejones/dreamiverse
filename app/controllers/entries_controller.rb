class EntriesController < ApplicationController
  before_filter :require_user, :only => [:new, :edit, :stream]
  before_filter :query_username, :except => [:stream, :random]

  def entry_list
    # This is an example of a hack due to tightly coupling Display to Data.
    session[:filters].delete(:type) if session[:filters]._?[:type] == "all entries"
    @entries = case session[:lens]
      when :field
        Entry.dreamfield(current_user, @user, session[:filters])
      when :stream
        Entry.dreamstream(current_user, session[:filters])
      else
        raise "invalid lens: #{session[:lens]}"
    end
  end
  
  def index
    if params[:entry_type]
      # TODO: Make this work without setting it
      params[:filters] ||= {}
      params[:filters][:type] = params[:entry_type]  
    end

    flash.keep and redirect_to(user_entries_path(@user.username)) unless params[:username]
    session[:lens] = :field
    session[:filters] = params[:filters]

    entry_list
    
    @user.starlight.add( 1 ) if unique_hit?

  end

  def show
    @entry = Entry.find params[:id]
    @entry_mode = 'show'
    flash.keep and redirect_to(user_entry_path(@entry.user.username, @entry)) unless params[:username]

    entry_list
    i = @entries.index {|e| e == @entry } || 0
    @previous = @entries[i-1]
    @next = @entries[i+1] || @entries[0]
    # @entry = @entries[i]
    deny and return unless user_can_access?

    @comments = @entry.comments.order('created_at') # .limit(10)
    @page_title = @entry.title
    
    if unique_hit?
      @entry.starlight.add( 1 )
      @entry.user.starlight.add( 1 )
    end
  end
  
  def new
    @entry = Entry.new
    @entry_mode = 'new'
  end
  
  def edit
    @entry = Entry.find params[:id]
    @entry_mode = 'edit'
    deny and return unless user_can_write?
    render :new
  end

  def create
 
    whats = (params[:what_tags] || []).map {|word| What.for word }
    
    params[:entry][:dreamed_at] = parse_time(params[:dreamed_at])

    # replace this with a redirect/alert later
    params[:entry][:body] = 'My Dream...' if params[:entry][:body].blank?
        
    new_entry = current_user.entries.create!(params[:entry].merge(
      whats: whats
    ))
    redirect_to user_entry_path(current_user.username, new_entry)
  end
  
  def update
    @entry = Entry.find params[:id]
    deny and return unless user_can_write?
   
    # replace this with a redirect/alert later
    params[:entry][:body] = 'My Dream...' if params[:entry][:body].blank?
    
    params[:entry][:dreamed_at] = parse_time(params[:dreamed_at])

    @entry.set_whats(params[:what_tags])

    if @entry.update_attributes(params[:entry])
      respond_to do |format|
        format.html { redirect_to :action => :show, :id => params[:id] }
        format.json { render :json => {type: 'ok', message: 'entry updated'}}
      end
    else
      respond_to do |format|
        format.json { render :json => {type: 'error', errors: @entry.errors}}.to_json
      end
    end
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
    @filters = 'test'
    
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

  def random
    random_entry = Entry.random
    redirect_to user_entry_path(random_entry.user.username, random_entry.id)
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
