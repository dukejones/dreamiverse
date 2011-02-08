class DreamsController < ApplicationController
  before_filter :require_user, :except => [:stream]
  before_filter :require_username
  before_filter :query_username

  def query_username
    @user = User.find_by_username( params[:username] )

    redirect_to root_path, :alert => "user #{params[:username]} does not exist." and return unless @user
  end
  
  def index
    # public dreams only if != current_user
    @dreams = @user.dreams
    
    add_starlight @user, 1 if unique_hit?
  end

  def show
    @dream = Dream.find params[:id]

    if unique_hit?
      add_starlight @dream, 1
      add_starlight current_user, 1
    end
  end
  
  def new
    @dream = Dream.new
  end
  
  def edit
    @dream = Dream.find params[:id]
    render :new
  end

  def create
    new_dream = current_user.dreams.create!(params[:dream])
    redirect_to dream_path(new_dream)
  end
  
  def destroy
    @dream = Dream.find params[:id]
    @dream.destroy
    redirect_to :index
  end

  def stream
    @dreams = Dream.all
  end
end
