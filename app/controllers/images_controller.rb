class ImagesController < ApplicationController
  # GET /images
  # GET /images.json
  def index
    if params[:artist] && params[:album]
      @images = Image.where(artist: params[:artist], album: params[:album])
    elsif params[:q] # search
      @images = Image.search(params) # takes filters etc as well
    elsif params[:ids]
      @images = Image.where(id: params[:ids].split(','))
    else
      @images = Image.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => @images }
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

  # TODO: this error handling is not the most elegant
  def handle_upload
    file_contents = request.body.read
    write_image(file_contents)
    write_image(file_contents, "62x62")
    write_image(file_contents, "100x100")
    write_image(file_contents, "126x126")
    nil # return nothing for success
  rescue Exception => e
    e
  end
  
  def write_image(file_contents, extra=nil)
    extra = "-#{extra}" if extra
    file = File.open("#{RAILS_ROOT}/public/images/uploads/#{@image.id}#{extra}.#{@image.format}", "wb")
    file.write(file_contents)
    file.close
  end

  # POST /images
  # POST /images.json
  def create
    # return handle_upload if params['qqfile']
    
    @image = Image.new(params[:image])

    extension = params[:qqfile].split('.').last
    @image.format = extension
    # HACK HACK HACK!
    @image.format = "jpg"

    respond_to do |format|
      if !@image.save
        format.html { render :action => "new" }
        format.json  { render :json => @image.errors, :status => :unprocessable_entity }
      elsif (e = handle_upload).is_a?(Exception)
        format.html { render :action => "new" }
        format.json  { render :json => e.message, :status => :unprocessable_entity }
      else
        format.html { redirect_to(@image, :notice => 'Image was successfully created.') }
        format.json  { render :json => "{success:true,id:#{@image.id}}", :status => :created }
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

end
