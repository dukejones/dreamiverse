class HomeController < ApplicationController
  layout 'home'
  
  def index
    if current_user
      flash.keep
      redirect_to :dreams
    end

    @user = User.new(:username => "username")
  end
end
