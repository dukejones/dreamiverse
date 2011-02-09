class AlbumsController < ApplicationController

  # GET /albums.json
  def index
    image_finder = Image.where({})
    image_finder = image_finder.where(section: params[:section]) if params[:section]
    image_finder = image_finder.where(genre: params[:genre]) if params[:genre]

    if params.has_key?(:artist)
      params[:artist] = nil if ["null", "", "Unknown"].include?(params[:artist])
      image_finder = image_finder.where(artist: params[:artist])
      @albums = {}
      image_finder.each do |image|
        @albums[image.album] ||= []
        @albums[image.album] << image
      end
    elsif params[:starts_with]
      @albums = image_finder.where("album LIKE ?", "#{params[:starts_with]}%").albums
    end

    respond_to do |format|
      format.html { render(partial:"images/browser/album") }
      format.json { render :json => @albums }
    end
  end

end
