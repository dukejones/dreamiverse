class User::SessionsController < ApplicationController
  def new
    flash.keep
    redirect_to root_path
  end

  def create
    
  end
  
  def destroy
    
  end
end

