class ArtistsController < ApplicationController

  # GET /artists.json
  def index
    image_finder = Image.where(true)
    image_finder = image_finder.where(section: params[:section]) if params[:section]

    if params[:genre]
      images = image_finder.where(genre: params[:genre])
      
      @artists = {}
      images.each do |image|
        @artists[image.artist] = image
      end
    elsif params[:starts_with]
      @artists = image_finder.where("artist LIKE ?", "#{params[:starts_with]}%").artists
    end

    respond_to do |format|
      # format.html # index.html.erb
      format.json  { render :json => @artists }
    end
  end

end
