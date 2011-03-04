class User::SessionsController < ApplicationController
  layout 'home'

  def new
    redirect_to :root and return if current_user
    
    render "users/login"
  end

  def create
    debugger
    if user = User.authenticate(params[:user])
      set_current_user user
      flash.notice = 'logged in.'
    else
      flash.alert = "incorrect username / password"
    end
    
    begin
      redirect_to :back
    rescue RedirectBackError
      redirect_to :root
    end
  end

  def destroy
    set_current_user(nil)
    redirect_to :root
  end
end

