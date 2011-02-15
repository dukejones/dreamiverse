class EntriesController < ApplicationController
  before_filter :require_user, :except => [:stream]
  before_filter :query_username, :except => [:stream]

  def index
    redirect_to(user_entries_path(@user.username)) unless params[:username]

    # TODO: Write a custom finder for this SLOW method!
    @entries = @user.entries.order('created_at DESC').select {|e| current_user.can_access?(e) }
    
    add_starlight @user, 1 if unique_hit?
  end

  def show
    @entry = Entry.find params[:id]
    restrict_access
    redirect_to(user_entry_path(@entry.user.username, @entry)) unless params[:username]
    
    if unique_hit?
      add_starlight @entry, 1
      add_starlight current_user, 1
    end
  end
  
  def new
    @entry = Entry.new
  end
  
  def edit
    @entry = Entry.find params[:id]
    restrict_write
    render :new
  end

  def create
    what_names = params[:what_tags] || []
    whats = what_names.map {|name| What.find_or_create_by_name name }

    new_entry = current_user.entries.create!(params[:entry].merge(whats: whats))
    redirect_to user_entry_path(current_user.username, new_entry)
  end
  
  def update
    @entry = Entry.find params[:id]
    restrict_write

    what_names = params[:what_tags] || []
    whats = what_names.map {|name| What.find_or_create_by_name name }
    whats.each { |what| @entry.add_what_tag(what) }

    @entry.update_attributes( params[:entry] )    
    redirect_to :action => :show, :id => params[:id]
  end
  
  def destroy
    @entry = Entry.find params[:id]
    restrict_write
    
    @entry.destroy
    redirect_to :index
  end

  def stream
    @user = current_user

    # where dream is public
    # or i am friends with entry.user
    # but not my own dreams
    @entries = Entry.where(
      (
        { sharing_level: Entry::Sharing[:everyone] } | 
        (
          { sharing_level: Entry::Sharing[:friends] } & 
          { user: { following: current_user, followers: current_user} }
        ) 
      ) &
      (:user_id ^ current_user.id)
    ).joins(:user.outer => [:following.outer, :followers.outer])
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
  def restrict_access
    deny unless current_user.can_access?(@entry)
  end

  # requires @entry be set
  def restrict_write
    deny unless current_user == @entry.user
  end
  
  def deny
    redirect_to :root, :warn => "Access denied to this entry." and return
  end
end
