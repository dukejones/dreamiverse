class ImagesController < ApplicationController
  protect_from_forgery :except => :create
  #before_filter :require_moderator, :only => :manager

  def index
    image_scope = Image.enabled
    image_scope = image_scope.where(section: params[:section]) if params.has_key?(:section)
    image_scope = image_scope.where(category: params[:category]) if params.has_key?(:category)
    image_scope = image_scope.where(genre: params[:genre]) if params.has_key?(:genre)
    
    if params.has_key?(:artist) && params.has_key?(:album)
      params[:album] = nil if params[:album] == "null"
      params[:artist] = nil if params[:artist] == ""
      @images = image_scope.where(artist: params[:artist], album: params[:album])
    elsif params[:q] # search
      @images = image_scope.search(params) # takes filters etc as well
    elsif params[:ids]
      @images = image_scope.where(id: params[:ids].split(','))
    else
      @images = image_scope.all
    end

    respond_to do |format|
      format.html do
        render :partial => 'image_browser' if request.xhr?
        # otherwise, index.html.erb
      end
      format.json do 
        if params[:ids_only]
          render :json => @images.map(&:id)
        else
          render :json => @images
        end
      end
    end
  end
  
  def artists
    image_finder = Image.enabled
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
  
  def albums
    image_finder = Image.enabled
    image_finder = image_finder.where(section: params[:section]) if params[:section]
    image_finder = image_finder.where(category: params[:category]) if params[:category]
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
      format.html { render(partial:"images/browser/albums") }
      format.json { render :json => @albums }
    end
  end
  
  def slideshow
    respond_to do |format|
      format.html { render(partial:"images/browser/slideshow") }
    end
  end
  
  def manager
    respond_to do |format|
      format.html { render(partial:"images/browser/manage") }
    end
  end

  def show
    @image = Image.find(params[:id])
  
    respond_to do |format|
      format.html # show.html.erb
      format.json  { render :json => @image }
    end
  end


  def create
    image_data = {
      incoming_filename: params[:qqfile],
      uploaded_by: current_user
    }
    
    if params.has_key?(:id)
      @image = Image.find(params[:id])
      @image.update_attributes(image_data.merge(enabled: true))
    
    elsif params.has_key?(:image)
      @image = Image.new(params[:image].merge(image_data))
      
    end

    if @image.save
      @image.write(request.body.read)
      
      respond_to do |format|
        format.html { render :text => 'Image was successfully created.' }
        format.json  { 
          render :json => {image_url: @image.url(:thumb), image: @image}.to_json, :status => :created
        }
      end
    else
      respond_to do |format|
        format.html { render :action => "new", :alert => "Could not upload the file." }
        format.json  { render :json => @image.errors, :status => :unprocessable_entity }
      end
    end
  rescue => e
    Rails.logger.warn "Error uploading file: #{e.message}"
    respond_to do |format|
      format.html { render :text => "Could not upload the file." }
      format.json  { render :json => e.message, :status => :unprocessable_entity }
    end
  end


  def update
    @image = Image.find(params[:id])

    if @image.update_attributes(params[:image].merge(enabled: true))
      respond_to do |format|
        format.html { render :text => 'Image was successfully updated.' }
        format.json  { render json: {type: 'ok', message: 'Image was successfully updated.'} }
      end
    else
      respond_to do |format|
        format.html { render :action => "edit" }
        format.json  { render :json => { type: 'error', errors: @image.errors, status: :unprocessable_entity } }
      end
    end
  end
  
  def updatefield    
    image_finder = Image.enabled
    image_finder = image_finder.where(section: params[:section]) if params.has_key?(:section)
    image_finder = image_finder.where(category: params[:category]) if params.has_key?(:category)
    image_finder = image_finder.where(artist: params[:artist]) if params.has_key?(:artist)
    image_finder = image_finder.where(album: params[:album]) if params.has_key?(:album)
    
    errors = ''
    image_finder.each do |image|
      if params.has_key?(:new_album)
        if not image.update_attribute(:album, params[:new_album]) 
          errors += image.errors
        end
      elsif params.has_key?(:new_artist)
        if not image.update_attribute(:artist, params[:new_artist])
          errors += image.errors
        end
      end
    end
    
    respond_to do |format|
      if errors == ''
        format.html { render :text => 'Images were successfully updated.' }
        format.json  { render json: {type: 'ok', message: 'Images were successfully updated.'} }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => { type: 'error', errors: errors, status: :unprocessable_entity } }
      end
    end
  end

  def disable
    @image = Image.find(params[:id])
    respond_to do |format|
      if @image.update_attribute(:enabled, false)
        format.html { redirect_to(url_for(@image), :notice => 'Image was disabled.') }
        format.json  { head :ok }
      else
        format.html { redirect_to(url_for(@image), :alert => 'Could not disable the image.') }
        format.json  { render :json => @image.errors, :status => :unprocessable_entity }
      end
    end
    
  end
  
  
  def destroy
    @image = Image.find(params[:id])
    @image.destroy

    respond_to do |format|
      format.html { redirect_to(images_url) }
      format.json  { head :ok }
    end
  end

  # This method is called when a url for a size image that has not yet been generated is requested.
  def resize
    # image = Image.find params[:id]
    image = Image.where(image_path: "#{params[:year]}/#{params[:month]}/#{params[:filename]}.#{params[:format]}").last

    unless image && File.exists?(image.file_path)
      Rails.logger.warn("cannot find image!")
      render(nothing: true, status: 404) and return 
    end

    format = params[:format] || image.format
    mime_type = Mime::Type.lookup_by_extension(format)
    unless mime_type
      mime_type = "image/jpeg"
      format = "jpg"
    end
    options = { :size => params[:size], :format => format }
    image.generate(params[:descriptor], options)

    send_file image.file_path(params[:descriptor], options), {type: mime_type, disposition: 'inline'}

    # redirect_to image.url(params[:descriptor], options)
    # For future Rails Release (3.1?): Streaming / Chunked response.
    # self.response_body = proc {|response, output|
    #   break if @run; @run = true # bug in Rails 3.0.x - Runs this proc twice.
    #   open(image.path(params[:descriptor], options)) do |f|
    #     f.each_chunk(4096) {|chunk| response.write(chunk) }
    #   end
    # }
  end
  

end
