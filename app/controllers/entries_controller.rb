class EntriesController < ApplicationController
  before_filter :require_user, :only => [:new, :edit, :stream]
  before_filter :query_username, :except => [:stream, :random]

  def entry_list
    # This is an example of a hack due to tightly coupling Display to Data.
    session[:filters].delete(:type) if session[:filters]._?[:type] == "all entries"
    @entries = case session[:lens]
      when :stream
        Entry.dreamstream(current_user, session[:filters])
      else # when :field
        Entry.dreamfield(current_user, @user, session[:filters])
    end
  end
  
  def index
    # TODO: Make this work without setting it manually.
    params[:filters] ||= {}
    params[:filters][:type] = params[:entry_type].singularize if params[:entry_type]    
    params[:filters][:page] = params[:page]
    params[:filters][:page_size] = 10
    
    @type_filter = params[:filters]._?[:type]
    @page_size = params[:filters][:page_size]
    @view_all_mode = true if params[:page] == 'all'
    
    flash.keep and redirect_to(user_entries_path(@user.username)) and return unless params[:username] || request.xhr?
    session[:lens] = :field
    session[:filters] = params[:filters]

    entry_list
    
    hit( @user )

    if request.xhr?
      thumbs_html = ""
      @entries.each { |entry| thumbs_html += render_to_string(:partial => 'thumb_2d', :locals => {:entry => entry}) }
      render :json => {type: 'ok', html: thumbs_html}
    end

  end

  def show
    @entry = Entry.find params[:id]
    @entry_mode = 'show'
    flash.keep and redirect_to(user_entry_path(@entry.user.username, @entry)) unless params[:username]

    entry_list
    i = (@entries.index {|e| e == @entry }) || 0
    @previous = @entries[i-1]
    @next = @entries[i+1] || @entries[0]
    # TODO: Remove this.
    @next = @entry unless @next
    @previous = @entry unless @previous
    deny and return unless user_can_access?

    @comments = @entry.comments.order('created_at') # .limit(10)
    @page_title = @entry.title
    
    hit( @entry )
    hit( @entry.user )
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
    where = Where.for params[:entry].delete(:location_attributes)
    params[:entry][:location_id] = where.id if where
    params[:entry][:dreamed_at] = parse_time(params[:dreamed_at])

    @entry = current_user.entries.create(params[:entry])
    @entry.set_whats(params[:what_tags])
    @entry.set_links(params[:links])
    @entry.set_emotions(params[:emotions])

    if @entry.valid?
      redirect_to user_entry_path(current_user.username, @entry)
    else
      @entry_mode = 'new'
      flash.now[:alert] = @entry.errors.full_messages.first
      render :new
    end
  end
  
  def update
    @entry = Entry.find params[:id]
    deny and return unless user_can_write?
    
    params[:entry][:dreamed_at] = parse_time(params[:dreamed_at])
    params[:entry][:image_ids] = [] unless params[:entry].has_key?(:image_ids)
    
    @entry.set_whats(params[:what_tags])
    @entry.location = Where.for params[:entry].delete(:location_attributes)
    @entry.set_links(params[:links])
    @entry.set_emotions(params[:emotions])

    if @entry.update_attributes(params[:entry])
      respond_to do |format|
        format.html { redirect_to :action => :show, :id => params[:id] }
        format.json { render :json => {type: 'ok', message: 'entry updated'}}
      end
    else
      respond_to do |format|
        format.html { redirect_to edit_entry_path(params[:id]), alert: @entry.errors.full_messages.first }
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

  def set_view_preferences
    @entry = Entry.find(params[:id])
    @entry.view_preference.image = Image.find(params[:bedsheet_id]) unless params[:bedsheet_id].nil?
    @entry.view_preference.bedsheet_attachment = params[:scrolling] unless params[:scrolling].nil?
    @entry.view_preference.theme = params[:theme] unless params[:theme].nil?
    @entry.save!
    render :json => "entry view preferences updated"
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
