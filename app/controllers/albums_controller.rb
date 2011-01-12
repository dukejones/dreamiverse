class AlbumsController < ApplicationController

  # GET /albums.json
  def index
    @albums = Image.sectioned(params[:section]).by(params[:artist]).albums
    
    respond_to do |format|
      # format.html # index.html.erb
      format.json  { render :json => @albums }
    end
  end

end
