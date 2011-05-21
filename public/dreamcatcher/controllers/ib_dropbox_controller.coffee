$.Controller 'Dreamcatcher.Controllers.IbDropbox',

  model: Dreamcatcher.Models.ImageBank

  init: ->
    #@isDragging = false
    $('#dropbox .imagelist').html ''
    @imageCookie = new Dreamcatcher.Classes.CookieHelper 'ib_dropbox'
    @stateCookie = new Dreamcatcher.Classes.CookieHelper "ib_state", true
    @showImage imageId for imageId in @imageCookie.getAll() if @imageCookie.getAll()?

    $("#dropbox").offset @stateCookie.get() if @stateCookie.get()?
  
    # for adding images
    $("#dropbox").droppable {
      drop: (ev, ui) =>
        @addImage ui.draggable
    }

    # for removing images
    $('#bodyClick').droppable {
      drop: (ev, ui) =>
        @removeImage ui.draggable
    }

    $("#dropbox").draggable {
      handle: 'h2,.icon'
      stop: (ev, ui) =>
        @stateCookie.set ui.position
    }
    
  show: ->
    $('#dropbox').show()
  
  
  addImage: (el) ->
    imageId = el.data 'id'
    imageMeta = el.data 'image'
    if not @imageCookie.contains imageId
      @imageCookie.add imageId
      @showImage imageId, imageMeta
    else
      log 'already here' #todo - something better

  removeImage: (el) ->
    @imageCookie.remove el.data 'id'
    el.remove()
    
  showImage: (imageId, imageMeta) ->
    if imageMeta?
      $("#dropbox .imagelist").append @view('image',{ image: imageMeta })
      @registerDraggable $('#dropbox .imagelist li:last'), true
    else
      @model.getImage imageId, {}, @callback('showImage', imageId)
      
      
  #new: refactor
  registerDraggable: (el, fromDropbox) ->
    el.draggable {
      containment: 'document'
      helper: 'clone'
      zIndex: 100
      start: (ev, ui) =>
        ###
        #ev.target.className = 'grabbing'
        #$("#dropbox .active").hide()
        @isDragging = false
        ev.target.removeClass 'grabbing'
        ###
        if fromDropbox
          $("#dropbox").css('z-index','1100')
          $("#bodyClick").show()
      stop: (ev, ui) =>
        #ui.draggable.removeClass 'grabbing'
        if fromDropbox
          $("#dropbox").css('z-index','')
          $("#bodyClick").hide()
    }
  
  registerDroppable: (el) ->
    el.droppable {  
      drop: (ev, ui) =>
        
        dropTo = $(ev.target).parent()
        album = dropTo.data 'album'
        imageMeta = ui.draggable.data 'image'
        return if imageMeta.album is album
        imageId = ui.draggable.data 'id'
        
        @model.update imageId, {image: {album: album} }, (imageId, album) =>
          ui.draggable.appendTo $('td',dropTo)
          imageMeta = ui.draggable.data 'image'
          imageMeta.album = album
          ui.draggable.data 'image', imageMeta
          @registerDraggable ui.draggable, false
    
    }

    
  '#dropbox .cancel click': (el) -> #TODO: fix
    @imageCookie.clear()
    $('#dropbox .imagelist').html ''
  
  '#dropbox .manage click': (el) ->
    @ibBrowser.showManager $('#dropbox li'), 'Drop box'
  
  '#dropbox li .close click': (el) ->
    @removeImage el.parent()
  
  '#dropbox .play click': (el) ->
    @ibBrowser.showSlideshow $('#dropbox li')