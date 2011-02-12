class EntriesController < ApplicationController
  before_filter :require_user, :except => [:stream]
  # before_filter :ensure_username_url, :only => [:index, :show]
  before_filter :query_username, :except => [:stream]

  def ensure_username_url
    # if !params[:username]
    #   if current_user
    #     redirect_to(url_for(params.merge(username: current_user.username))) and return 
    #   else
    #     redirect_to root_path, :alert => "you must be logged in to access this page." and return
    #   end
    # end
  end


  def query_username
    @user = params[:username] ? User.find_by_username( params[:username] ) : current_user
    redirect_to root_path, :alert => "no user #{params[:username]}" and return unless @user
  end
  
  def index
    redirect_to(user_entries_path(@user.username)) unless params[:username]
    # public entries only if != current_user
    @entries = @user.entries
    
    add_starlight @user, 1 if unique_hit?
  end

  def show
    @entry = Entry.find params[:id]
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
    render :new
  end

  def create
    what_names = params[:what_tags]
    whats = what_names.map {|name| What.find_or_create_by_name name }

    new_entry = current_user.entries.create!(params[:entry].merge(whats: whats))
    redirect_to user_entry_path(current_user.username, new_entry)
  end
  
  def update
    what_names = params[:what_tags]
    whats = what_names.map {|name| What.find_or_create_by_name name }
    
    @entry = Entry.find params[:id]

    whats.each { |what| @entry.add_what_tag(what) }

    @entry.update_attributes( params[:entry] )    
    redirect_to :action => :show, :id => params[:id]
  end
  
  def destroy
    @entry = Entry.find params[:id]
    @entry.destroy
    redirect_to :index
  end

  def stream
    @entries = Entry.all
    @user = current_user
  end
end
