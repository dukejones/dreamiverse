class User::SessionsController < ApplicationController

  def create
    if user = User.authenticate(params[:user])
      set_current_user user
      flash.notice = 'logged in.'
    else
      flash.alert = "the provided credentials did not match a dreamcatcher user."
    end
    
    redirect_to :root
  end

  def destroy
    set_current_user(nil)
    redirect_to :root
  end
end

