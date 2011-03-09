class HomeController < ApplicationController
  layout 'home'

  def index
    if current_user
      flash.keep
      redirect_to entries_path
    end

    @entries = Entry.where(:created_at > 1.week.ago).
      order_by_starlight.limit(8)
  end

  def parse_url_title
    @url = params[:url]
    @title = ExternalUrl.title(@url)
    render :json => {:title => @title}
  end

  def feedback
    render "feedback"
  end

  def submit_feedback
    AdminMailer.feedback_email( current_user, params[:feedback] ).deliver
  end
  
  def terms
    render "terms"
  end

end
