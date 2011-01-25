class ArtistsController < ApplicationController

  # GET /artists.json
  def index
    if params[:genre]
      @artist_names = Image.sectioned(params[:section]).where(genre: params[:genre]).artists << nil
      @artists = @artist_names.map do |name|
        {name: name, images: Image.sectioned(params[:section]).where(artist: name).limit(6)}
      end
    elsif params[:starts_with]
      @artists = Image.sectioned(params[:section]).where("artist LIKE ?", "#{params[:starts_with]}%").artists
    end

    respond_to do |format|
      # format.html # index.html.erb
      format.json  { render :json => @artists }
    end
  end

end
