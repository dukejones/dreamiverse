$.Controller 'Dreamcatcher.Controllers.ImageBank.Manager',

  model: Dreamcatcher.Models.Image
  
  getView: (url, data) ->
    return @view "//dreamcatcher/views/images/manager/#{url}.ejs", data

  init: ->
    @meta = new Dreamcatcher.Controllers.ImageBank.ManagerMeta $("form#manager")
    @meta.manager = this

    @upload = new Dreamcatcher.Controllers.Common.Upload $('#uploader')
    @upload.load()
    @setDefaultUploadParams()

    @enableShiftKey()
  
  enableShiftKey: ->
    @shiftDown = false
    @ctrlDown = false
    $(document).keydown (event) =>
      @shiftDown = event.shiftKey
      @ctrlDown = event.altKey
      return
    $(document).keyup (event) =>
      @shiftDown = event.shiftKey
      @ctrlDown = event.altKey
      return
      
  close: (showSearch) ->
    @parent.showBrowser true, showSearch
    $("#frame.manager").fadeOut 'fast'
    
  show: (images, title) ->
    $("#frame.manager h1").text title if title?
    @isDropbox = title.trim().toLowerCase() is 'drop box'
    @showImages images if images?
    $("#frame.manager").fadeIn 'fast'
      
    
  #- loads all meta for a list of images
  showImages: (images) ->
    $("#imagelist").html ''
    @showImage image for image in images

  #- add image Html to the Dom
  showImage: (image, replaceElement) ->
    html = @getView 'image_show', image
    if replaceElement?
      replaceElement.replaceWith html
      
      if @isDropbox
        @parent.addImageToDropbox @getImageElement image.id
      
    else
      $("#imagelist").append html
    
  updateMeta: ->
    @meta.update()
    
  getMeta: (type) ->
    return @meta.get type
    
  '.browseWrap click': ->
    @close()
    
  '.searchWrap click': ->
    @close true
    
    
  ##-- SELECTOR --##

  #- select all/select none
  '.all click': (el) ->

    #todo: have both all and none
    if el.text().indexOf 'all' isnt -1
      $('#imagelist li').addClass 'selected'
      el.text 'select none'
    else
      $('#imagelist li').removeClass 'selected'
      el.text 'select all'

    @updateMeta()

  '.clearImages click': (el) ->
    $('#imagelist').html ''

  #- select individual images

  '#imagelist li click': (el) ->
    return if el.hasClass 'uploading'

    if @shiftDown
      @selectRange el 

    else if @ctrlDown
      if el.hasClass 'selected'
        el.removeClass 'selected'
      else
        el.addClass 'selected'

    else
      if el.hasClass 'selected'
        el.removeClass 'selected'
      else
        $('#imagelist li').removeClass 'selected'
        el.addClass 'selected'

    @updateMeta()

  selectRange: (el) ->
    firstIndex = $('#imagelist li.selected:first').index()
    lastIndex = $('#imagelist li.selected:last').index()
    currentIndex = el.index()
    fromIndex = Math.min firstIndex, currentIndex
    toIndex = Math.max lastIndex, currentIndex
    $('#imagelist li').removeClass 'selected'
    $('#imagelist li').each (i, el) =>
      $(el).addClass 'selected' if i >= fromIndex and i <= toIndex  

  #- delete individual image
  '#imagelist .close click': (el) ->
    if el.parent().hasClass 'delete'
      imageId = el.parent().data 'id'
      el.parent().hide()
    else
      el.parent().addClass 'delete'

  '.dontDelete click': (el) ->
    el.closest('li').removeClass 'delete'
  
  
  ##--- BUTTONS ---##

  #- resets all data to original
  '.reset click': (el) ->
    $("#imagelist li").removeClass 'selected'
    @displayMetaData {}
    $('#imagelist li').each (i, el) =>
      imageId = $(element).data 'id'
      @model.get imageId, {}, (imageMeta) =>
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
        @model.update imageId, {image: imageMeta}, @closeOnAllSaved()
      else
        @model.disable imageId, {}, @closeOnAllSaved()
        
  getImageElement: (imageId) ->
    return $("#imagelist li[data-id=#{imageId}]")
        
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
      notice 'image details have been updated'
          
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

  setDefaultUploadParams: ->
    @upload.setParams @getMeta 'organization' #if not @replaceImageId?
    

  