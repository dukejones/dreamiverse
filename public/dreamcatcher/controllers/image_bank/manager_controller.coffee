$.Controller 'Dreamcatcher.Controllers.ImageBank.Manager',

  imageModel: Dreamcatcher.Models.Image
  ibModel: Dreamcatcher.Models.ImageBank
  
  getView: (url, data) ->
    return @view "//dreamcatcher/views/image_bank/manager/#{url}.ejs", data

  init: ->
    @uploader = new Dreamcatcher.Controllers.ImageBank.ManagerUploader $("#uploader")
    @selector = new Dreamcatcher.Controllers.ImageBank.ManagerSelector $("#uploader")
    @meta = new Dreamcatcher.Controllers.ImageBank.ManagerMeta $("form#manager")
    
    @uploader.manager = this
    @selector.manager = this
    @meta.manager = this
    
  isDropbox: ->
    return $('frame.manager h1').text() is 'Drop box'
      
  close: ->
    @parent.setDropboxImages $('#imagelist li') if @isDropbox()
    @parent.showBrowser true
    
    $("#frame.manager").hide()
    
  show: (images, title) ->
    $("#frame.manager h1").text title if title?
    @showImages images if images?
    $("#frame.manager").show()
      
  '.browseWrap click': ->
    @close()
    
  #- loads all meta for a list of images
  showImages: (images) ->
    $("#imagelist").html ''
    @showImage image for image in images

  #- add image Html to the Dom
  showImage: (image, replaceElement) ->
    html = @getView 'image_show', image
    if replaceElement?
      replaceElement.replaceWith html
    else
      $("#imagelist").append html
    
    
  updateMeta: ->
    @meta.update()
    
  getMeta: (type) ->
    return @meta.get type
  
  ##--- BUTTONS ---##

  #- resets all data to original
  '.reset click': (el) ->
    $("#imagelist li").removeClass 'selected'
    @displayMetaData {}
    $('#imagelist li').each (i, el) =>
      imageId = $(element).data 'id'
      @imageModel.get imageId, {}, (imageMeta) =>
        $(el).data 'image', imageMeta
      $(el).show()
      
  #- saves all data and goes back to ib_browser
  '.save click': (el) ->
    @showSavingSpinner()
    
    @totalToSave = $('#imagelist li').length
    @totalSaved = 0
  
    $('#imagelist li').each (i, el) =>
      imageId = $(el).data 'id'
      imageMeta = @getMetaToSave $(el)
      if $(el).is ":visible"
        @imageModel.update imageId, {image: imageMeta}, @closeOnAllSaved()
      else
        @imageModel.disable imageId, {}, @closeOnAllSaved()
        
  getMetaToSave: (el) ->
    imageMeta = el.data 'image'
    delete imageMeta.date
    delete imageMeta.user
    imageMeta.section = imageMeta.type
    return imageMeta
    
  closeOnAllSaved: ->
    @totalSaved++
    if @totalToSave is @totalSaved
      @hideSavingSpinner()
      @close()
      @parent.showMessage 'your image details have been updated'
          
  showSavingSpinner: ->
    $(".save span").hide()
    $(".save .spinner, .save .saving").show()
  
  hideSavingSpinner: ->
    $(".save span").show()
    $(".save .spinner, .save .saving").hide()

  #- cancels all data changes and goes back to ib_browser
  '.cancel click': (el) ->
    $('#imagelist').html ''
    @close()