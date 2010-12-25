class DreamsController < ApplicationController
  def index
    @dreams = Dream.all
  end

  def show
    @dream = Dream.find params[:id]
  end
  
  def new
    @dream = Dream.new
  end

  def create
    current_user.dreams.create!(params[:dream])
    redirect_to :action => :index
  end
end
