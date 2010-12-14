class HomeController < ApplicationController
  def index
    if current_user
      render :text => "logged in" and return
    end
    @email = "phong@dreamcatcher.net"
    @user = User.first
  end
end
