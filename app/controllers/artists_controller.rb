class ArtistsController < ApplicationController

  # GET /artists.json
  def index
    @artist_names = Image.sectioned(params[:section]).where(genre: params[:genre]).artists
    @artists = @artist_names.map do |name|
      {name: name, images: Image.sectioned(params[:section]).where(artist: name).limit(6)}
    end

    respond_to do |format|
      # format.html # index.html.erb
      format.json  { render :json => @artists }
    end
  end

end
