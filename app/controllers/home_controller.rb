class HomeController < ApplicationController
  layout 'home'
  
  def index
    if current_user
      flash.keep
      redirect_to stream_path
    end

    # @user = User.new(:username => "username")
    @entries = Entry.where(:created_at > Time.now.yesterday).
      joins(:starlight).order('starlights.value DESC').limit(8)
  end
  
  def parse_url_title
    @url = params[:url]
    @title = ExternalUrl.title(@url)
    render :json => {:title => @title}
  end
end
