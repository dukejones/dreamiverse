class ArtistsController < ApplicationController

  # GET /artists.json
  def index
    image_finder = Image.where({})
    image_finder = image_finder.where(section: params[:section]) if params[:section]
    image_finder = image_finder.where(category: params[:category]) if params[:category]
    image_finder = image_finder.where(genre: params[:genre]) if params[:genre]

    if params[:starts_with]
      @artists = image_finder.where("artist LIKE ?", "#{params[:starts_with]}%").artists
    else
      @artists = {}
      image_finder.each do |image|
        @artists[image.artist] ||= []
        @artists[image.artist] << image unless @artists[image.artist].size >= 6
      end
    end

    respond_to do |format|
      format.html { render(partial: 'images/browser/artists') }
      format.json { render :json => @artists }
    end
  end

end
