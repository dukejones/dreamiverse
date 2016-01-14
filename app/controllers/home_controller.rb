class HomeController < ApplicationController
  layout 'home'

  def index
    # @entries = Entry.everyone.where(["created_at >= ?", 3.days.ago]).order("starlight DESC").limit(8)
    @entries = Entry.everyone.order("created_at DESC").limit(8)
  end

  def farewell
    # user = User.offset(rand(User.count)).first
    user = current_user
    # zipfile_name = UserExporter.new(user).generate_zip_file
    # send_file zipfile_name, type: Mime::ZIP
  end

  def landing_page
    unless current_user
      index
      render :index and return
    end

    case current_user.default_landing_page
    when 'stream' then redirect_to stream_path
    when 'home'   then redirect_to entries_path
    when 'today'  then redirect_to today_path
    end
  end

  def parse_url_title
    @url = params[:url]
    @title = ExternalUrl.title(@url) || @url
    render :json => {:title => @title}
  end

  def feedback
  end

  def submit_feedback
    AdminMailer.feedback_email( current_user, params[:feedback] ).deliver

    redirect_to entries_path, notice: "Your feedback has been submitted to the Dreamcatcher team.  Thank you."
  end

  def terms
  end

  def thank_you
    session[:thank_you] = true

    if request.xhr?
      render :json => {type: 'ok'}
    else
      redirect_to root_path
    end
  end

  def error
    raise "This is a test! This is only a test!"
  end
end
