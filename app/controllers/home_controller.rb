class HomeController < ApplicationController
  layout 'home'
  
  def index
    if current_user
      flash.keep
      redirect_to dreams_path
    end

    @user = current_user
  end
end
