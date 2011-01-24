class ImagesController < ApplicationController
  before_filter :require_user

  # GET /images
  # GET /images.json
  def index
    if params[:artist] && params[:album]
      @images = Image.sectioned(params[:section]).where(artist: params[:artist], album: params[:album])
    elsif params[:q] # search
      @images = Image.sectioned(params[:section]).search(params) # takes filters etc as well
    elsif params[:ids]
      @images = Image.where(id: params[:ids].split(','))
    else
      @images = Image.sectioned(params[:section]).all
    end

    respond_to do |format|
      format.html do
        render :partial => 'image_browser' if request.xhr?
        # otherwise, index.html.erb
      end
      format.json { render :json => @images }
    end
  end

  # GET /images/manage
  def manage
    respond_to do |format|
      format.html # manage.html.erb
      # format.json  { render :json => @images }
    end
  end

  # GET /images/1
  # GET /images/1.json
  def show
    @image = Image.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json  { render :json => @image }
    end
  end

  # # GET /images/new
  # # GET /images/new.json
  # def new
  #   @image = Image.new
  # 
  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.json  { render :json => @image }
  #   end
  # end

  # # GET /images/1/edit
  # def edit
  #   @image = Image.find(params[:id])
  # end

  # POST /images
  # POST /images.json
  def create
    @image = Image.new(params[:image].merge({
      incoming_filename: params[:qqfile],
      uploaded_by: current_user
    }))

    respond_to do |format|
      if !@image.save
        format.html { render :action => "new" }
        format.json  { render :json => @image.errors, :status => :unprocessable_entity }
      elsif (e = @image.write(request.body.read)).is_a?(Exception)
        format.html { render :action => "new" }
        format.json  { render :json => e.message, :status => :unprocessable_entity }
      else
        format.html { redirect_to(@image, :notice => 'Image was successfully created.') }
        thumb_size = '120x120'
        @image.resize(thumb_size)
        format.json  { render :json => {image_url: @image.url(thumb_size), image: @image}.to_json, :status => :created }
      end
    end
  end

  # PUT /images/1
  # PUT /images/1.json
  def update
    @image = Image.find(params[:id])

    respond_to do |format|
      if @image.update_attributes(params[:image])
        format.html { redirect_to(@image, :notice => 'Image was successfully updated.') }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @image.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image = Image.find(params[:id])
    @image.destroy

    respond_to do |format|
      format.html { redirect_to(images_url) }
      format.json  { head :ok }
    end
  end

  # this method is called when a url for a size image that has not yet been generated is requested.
  # it expects a binary response.
  # this may be a prime place for optimization.
  def resize
    raise "Realtime resizing not yet implemented."
  end
end
