class EntriesController < ApplicationController
  before_filter :require_user, :except => [:stream, :show]
  before_filter :query_username, :except => [:stream]

  def index
    redirect_to(user_entries_path(@user.username)) unless params[:username]

    # TODO: Write a custom finder for this SLOW method!
    @entries = @user.entries.order('created_at DESC').select {|e| current_user.can_access?(e) }
    @entries = @entries.where(type: params[:type]) if params[:type]

    @user.starlight.add( 1 ) if unique_hit?
  end

  def show
    @entry = Entry.find params[:id]
    deny and return unless user_can_access?
    redirect_to(user_entry_path(@entry.user.username, @entry)) unless params[:username]

    @comments = @entry.comments.limit(10)
    
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
    what_names = params[:what_tags] || []
    whats = what_names.map {|name| What.find_or_create_by_name name }

    new_entry = current_user.entries.create!(params[:entry].merge(
      whats: whats,
      view_preference_attributes: params[:entry].delete(:view_preference)
    ))
    redirect_to user_entry_path(current_user.username, new_entry)
  end
  
  def update
    @entry = Entry.find params[:id]
    deny and return unless user_can_write?

    what_names = params[:what_tags] || []
    whats = what_names.map {|name| What.find_or_create_by_name name }
    whats.each { |what| @entry.add_what_tag(what) }

    @entry.update_attributes( params[:entry].merge(
      view_preference_attributes: params[:entry].delete(:view_preference)
    ) )
    redirect_to :action => :show, :id => params[:id]
  end
  
  def destroy
    @entry = Entry.find params[:id]
    deny and return unless user_can_write?
    
    @entry.destroy
    redirect_to :index
  end

  def stream
    @user = current_user
    @entries = Entry.accessible_by(current_user)
    
    # starlight: low, medium, high, off
    # for now just high
    if params[:starlight_filter] == 'high'
      @entries = @entries.order_by_starlight
    else
      @entries = @entries.scoped.order('updated_at DESC')
    end
    # Type: visions,  dreams,  experiences
    if params[:type_filter]
      @entries = @entries.where(type: params[:type_filter])
    end
    # friends, or following
    if params[:friend_filter] == 'friends'
      @entries = @entries.friends_with(current_user)
    elsif params[:friend_filter] == 'following'
      @entries = @entries.followed_by(current_user)
    end
    
    # not my own dreams
    # @entries = @entries.where(:user_id ^ current_user.id)
    @entries = @entries.limit(50)
    @entries = @entries.offset(50 * params[:page]) if params[:page]
    
    if request.xhr?
      thumbs_html = ""
      @entries.each { |entry| thumbs_html += render_to_string(:partial => 'thumb_1d', :locals => {:entry => entry}) }
      render :text => thumbs_html
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
    redirect_to :root, :alert => "Access denied to this entry."
  end
  
end
