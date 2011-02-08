class HomeController < ApplicationController
  layout 'home'
  
  def index
    if current_user
      flash.keep
      redirect_to dreams_path(current_user.username)
    end

    @user = User.new(:username => "username")
  end
  
  def parse_url_title
    @url = params[:url]
    @title = ExternalUrl.title(@url)
    render :json => {:title => @title}
  end
end
