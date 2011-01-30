class AlbumsController < ApplicationController

  # GET /albums.json
  def index

    image_finder = Image.where(true)
    image_finder = image_finder.where(section: params[:section]) if params[:section]

    if params[:artist]
      params[:artist] = nil if (params[:artist] == "null" || params[:artist] == "")
      @albums = image_finder.where(artist: params[:artist]).albums
    elsif params[:starts_with]
      @albums = image_finder.where("album LIKE ?", "#{params[:starts_with]}%").albums
    end
    
    respond_to do |format|
      # format.html # index.html.erb
      format.json  { render :json => @albums }
    end
  end

end
