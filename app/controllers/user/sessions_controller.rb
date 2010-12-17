class User::SessionsController < ApplicationController
  def new
    flash.keep
    redirect_to root_path
  end

  def create
    auth = request.env["omniauth.auth"]
    raise auth.to_yaml
  end
  
  def destroy
    
  end
end

