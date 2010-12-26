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
    new_dream = current_user.dreams.create!(params[:dream])
    redirect_to dream_path(new_dream)
  end
end
