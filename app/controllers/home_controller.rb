class HomeController < ApplicationController
  helper 'devise'
  def index
    if current_user
      #render :text => "logged in" and return
      flash.now[:notice] = "user logged in."
    end
    #@email = "phong@dreamcatcher.net"
    @user = User.first
  end
end
