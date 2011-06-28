$.Controller 'Dreamcatcher.Controllers.Images.Dropbox', {
  pluginName: 'dropbox'
}, {

  model: Dreamcatcher.Models.Image  
  
  getView: (url, data, type) ->
    type = 'dropbox' if not type?
    return $.View "/dreamcatcher/views/images/#{type}/#{url}.ejs", data

  init: (el, parent) ->
    @scope = $(el)
    @parent = parent
    @imageCookie = new CookieHelper 'ib_dropbox'
    @stateCookie = new CookieHelper 'ib_state', true
    $('#dropbox .imagelist').html ''
    
    @showImage imageId for imageId in @imageCookie.getAll() if @imageCookie.getAll()?
    $("#dropbox").offset @stateCookie.get() if @stateCookie.get()?
    @initDragAndDrop()
  
  'images.dropbox.show subscribe': ->
    $('#dropbox').show()
    
  initDragAndDrop: ->
    # adding images
    $("#dropbox").droppable {
      drop: (ev, ui) =>
        @addImage ui.draggable
    }
    # removing images
    $('#bodyClick').droppable {
      drop: (ev, ui) =>
        @removeImage ui.draggable
    }
    # positioning drop box
    $("#dropbox").draggable {
      cursor: 'grabbing'
      handle: 'h2,.icon'
      stop: (ev, ui) =>
        @stateCookie.set ui.position
    }
    
  #- clearing images from UI and cookie
  clearImages: ->
    @imageCookie.clear()
    $('#dropbox .imagelist').html ''
  
  #- adding image to UI and cookie
  'dropbox.image.add': (called, el) ->
    @addImage el
  
  addImage: (el) ->
    imageId = el.data 'id'
    imageMeta = el.data 'image'
    if not imageId?
      notice 'error with image'
    else if not @imageCookie.contains imageId
      @imageCookie.add imageId
      @showImage imageId, imageMeta
    else
      notice 'image already exists in dropbox'
      
  #- remove image from UI and cookie
  removeImage: (el) -> 
    @imageCookie.remove el.data 'id'
    el.remove()
      
  #- setting the images from a list of elements
  setImages: (elements) ->
    elements.each (i, el) =>
      @addImage $(el)

  #- shows an image in the drop box
  showImage: (imageId, imageMeta) ->
    if imageMeta?
      $("#dropbox .imagelist").append @getView 'image', { image: imageMeta }
      @publish 'image.dropbox.drag', $('#dropbox .imagelist li:last')
    else
      @model.get imageId, {}, @callback('showImage', imageId)
  
  

    
  'image.dropbox.drag subscribe': (called, el) ->
    el.draggable {
      containment: 'document'
      helper: 'clone'
      #cursor: 'grabbing' # todo
      zIndex: 100
      start: (ev, ui) =>
        $("#bodyClick").show()
      stop: (ev, ui) =>
        $("#bodyClick").hide()
    }
  
  #- registers an element as droppable
  'dropbox.image.drop': (called, el) ->
    el.droppable {  
      drop: (ev, ui) =>  
        dropTo = $(ev.target).parent()
        album = dropTo.data 'album'
        imageMeta = ui.draggable.data 'image'
        return if imageMeta.album is album
        imageId = ui.draggable.data 'id'
        
        @model.update imageId, {image: {album: album} }, (imageId, album) =>
          ui.draggable.appendTo $('td', dropTo)
          imageMeta = ui.draggable.data 'image'
          imageMeta.album = album
          ui.draggable.data 'image', imageMeta
          @publish 'image.browser.drag', ui.draggable
    }
    
    
  #- View Events
    
  '.cancel click': (el) ->
    @clearImages()
  
  '.manage click': (el) ->
    @parent.showManager 'dropbox', 'Drop box'
  
  'li .close click': (el) ->
    @removeImage el.parent()
  
  '.play click': (el) ->
    @parent.showSlideshow 'dropbox'
    
  'li img dblclick': (el) ->
    imageId = el.parent().data 'id'
    @parent.showSlideshow 'dropbox', imageId
    
}