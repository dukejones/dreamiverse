class HomeController < ApplicationController
  layout 'home'

  def index
    if current_user
      flash.keep
      redirect_to stream_path
    end

    @users = User.all

    @entries = Entry.where(:created_at > Time.now.yesterday).
      order_by_starlight.limit(8)
  end
  
  def parse_url_title
    @url = params[:url]
    @title = ExternalUrl.title(@url)
    render :json => {:title => @title}
  end

  def faq
    render "home/faq"
  end

  def feedback
    render "home/feedback"
  end

end
