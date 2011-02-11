class EntriesController < ApplicationController
  before_filter :require_user, :except => [:stream]
  # before_filter :require_username, :only => [:index, :show]
  before_filter :query_username, :except => [:stream]

  def query_username
    @user = User.find_by_username( params[:username] )

    # redirect_to root_path, :alert => "user #{params[:username]} does not exist." and return unless @user
  end
  
  def index
    # public entries only if != current_user
    @entries = @user.entries
    
    add_starlight @user, 1 if unique_hit?
  end

  def show
    @entry = Entry.find params[:id]

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
    new_entry = current_user.entries.create!(params[:entry])
    redirect_to entry_path(current_user.username, new_entry)
  end
  
  def update
    @entry = Entry.find params[:id]
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
  end
end
