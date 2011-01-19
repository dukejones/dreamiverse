class AlbumsController < ApplicationController

  # GET /albums.json
  def index
    if params[:artist]
      @albums = Image.sectioned(params[:section]).by(params[:artist]).albums
    elsif params[:starts_with]
      @albums = Image.sectioned(params[:section]).where("album LIKE ?", "#{params[:starts_with]}%").albums
    end
    
    respond_to do |format|
      # format.html # index.html.erb
      format.json  { render :json => @albums }
    end
  end

end
