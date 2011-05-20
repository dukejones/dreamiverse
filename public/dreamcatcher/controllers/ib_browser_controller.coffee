$.Controller 'Dreamcatcher.Controllers.IbBrowser',

  model: Dreamcatcher.Models.ImageBank
  allViews: ['browse', 'genreList', 'artistList', 'albumList', 'searchOptions', 'searchResults', 'slideshow-back']
  
  init: ->
    
    @imageCookie = new Dreamcatcher.Classes.CookieHelper 'ib_dropbox'
    #@stateCookie = new Dreamcatcher.Classes.CookieHelper "ib_state"
    @displayScreen "browse", @view('types', { types: @model.types })
    @loadDropbox()
    
    $(document).keyup (event) ->
      #alert event.keyCode
      if event.keyCode is 37
        $(".footer .prev").click() if $(".footer .prev").is(":visible")
      if event.keyCode is 39
        $(".footer .next").click() if $(".footer .next").is(":visible")


  ## DROPBOX ##
  
  loadDropbox: ->
    $('#dropbox .imagelist').html ''
    @showImageInDropbox imageId for imageId in @imageCookie.getAll() if @imageCookie.getAll()?
    
    # for adding images
    $("#dropbox").droppable {
      drop: (ev, ui) =>
        @addImageToDropbox ui.draggable
    }
    
    # for removing images
    $('#bodyClick').droppable {
      drop: (ev, ui) =>
        @removeImageFromDropbox ui.draggable
    }
    
    $("#dropbox").draggable {
      handle: 'h2,.icon'
      stop: =>
        #updateState
    }

  #new: refactor
  setDraggable: (el, fromDropbox) ->
    el.draggable {
      containment: 'document'
      helper: 'clone'
      zIndex: 100
      start: ->
        $("#dropbox .active").show()
        el.addClass 'grabbing'
        ###
        #
        #if fromDropbox
          $("#dropbox").css('z-index',1200)
          $("#bodyClick").show()
        else
        ###
        #@dragging = true
      stop: ->
        $("#dropbox .active").hide()
        ###
        if fromDropbox
          $("#dropbox").css('z-index','')
          $("#bodyClick").hide()
        else
        ###
        #@dragging = false
          
    
    }

    
  setDroppable: (el) ->
    el.droppable {
      drop: (ev, ui) =>
        droppedTo = $(ev.target).parent()
        album = droppedTo.data 'album'
        imageMeta = ui.draggable.data 'image'
        return if imageMeta.album is album
        imageId = ui.draggable.data 'id'
        @model.update imageId, {image: {album: album} }, @callback('droppedToNewAlbum', imageId, album)
    }
  droppedToNewAlbum: (imageId, album)->
    imageElement = $(".img[data-id='#{imageId}']")
    albumElement = "tr.images[data-album='#{album}'] td"
    imageElement.appendTo albumElement
    imageMeta = imageElement.data 'image'
    imageMeta.album = album
    imageElement.data 'image', imageMeta
    @setDraggable imageElement, false

  addImageToDropbox: (el) ->
    imageId = el.data 'id'
    imageMeta = el.data 'image'
    if not @imageCookie.contains imageId
      @imageCookie.add imageId
      @showImageInDropbox imageId, imageMeta
    else
      log 'already here' #todo - something better

  showImageInDropbox: (imageId, imageMeta) ->
    if imageMeta?
      $("#dropbox .imagelist").append @view('dropboximage',{ image: imageMeta })
      @setDraggable $('#dropbox .imagelist li:last'), true
    else
      @model.getImage imageId, {}, @callback('showImageInDropbox', imageId)

  removeImageFromDropbox: (el) ->
    @imageCookie.remove el.data 'id'
    el.remove()
      
  '#dropbox .cancel click': (el) -> #TODO: fix
    @imageCookie.clear()
    $('#dropbox .imagelist').html ''
    
  '#dropbox .manage click': (el) ->
    @showManager $('#dropbox li'), 'Drop box'
    
  '#dropbox li .close click': (el) ->
    @removeImageFromDropbox el.parent()
    
  '#dropbox .play click': (el) ->
    @showSlides $('#dropbox li')


  
  
  ## GENERAL DISPLAY
  
  hideAllViews: ->
    for view in @allViews
      @lastView = view if $("##{view}").is(':visible') and view isnt 'searchOptions'
    return $('#'+@allViews.join(', #')).hide()
    
  showLastView: ->
    @displayScreen @lastView, null if @lastView?
    
  showIcons: (icons) ->
    $(".top,.footer").children().hide()
    $(icons,".top,.footer").show()    

  displayScreen: (type, html) ->
    switch type
      when 'browse'
        @category = null
        @showIcons '.browseHeader, .searchWrap'
        @updateScreen null, null, "#browse", null, html
        
      when 'artistList'
        @artist = null
        @showIcons '.backArrow, h1, .searchWrap'
        @updateScreen 'browse', 'browse', '#artistList', @category, html
        
      when 'albumList'
        @showIcons '.backArrow, h1, .play, .manage, .searchWrap, .drag'
        @updateScreen 'artistList', @category, '#albumList', @artist, html
        @setDroppable $('#albumList .images td')
        @setDraggable $("#albumList .images .img"), false
        
      when 'searchResults'
        @showIcons '.browseWrap, .searchFieldWrap, .drag'
        @updateScreen null, null, '#searchResults', null, html
      
        ### 
        when 'slideshow'
          @showIcons '.backArrow, h1, .counter, .prev, .info, .tag, .add, .next, .edit, .cancel'
          if @searchOptions?
            @updateScreen 'searchResults', 'Search', '#slideshow', 'slideshow', html
          else if @artist?
            @updateScreen 'albumList', @artist, '#slideshow', 'slideshow', html
          else
            @updateScreen 'artistList', @category, '#slideshow', 'slideshow', html
        ###
        
    @currentView = type

  updateScreen: (previousType, previousName, currentType, currentName, currentHtml, show) ->
    @hideAllViews()
    
    $(".backArrow .content span").text(previousName) if previousName
    if previousName is 'browse' then $('.backArrow .content .img').show() else $('.backArrow .content .img').hide()
    $('.backArrow').attr('name',previousType) if previousType
    $('#frame.browser h1').text(currentName) if currentName
    $(currentType).replaceWith(currentHtml) if currentHtml?
    $(currentType).show()
    
  getImagesFromElements: (elements) ->
    images = []
    elements.each (i,el) =>
      images[i] = $(el).data 'image'
    return images
    
  showManager: (elements, title) ->
    images = @getImagesFromElements elements
    
    if not $('#frame.manager').exists()
      $.get '/images/manage', (html) =>
        $('#frame.browser').hide().after html
        @ibManager = new Dreamcatcher.Controllers.IbManager $("#frame.manager") if not @ibManager
        @ibManager.showManager images, title
    else
      $('#frame.browser').hide()
      @ibManager.showManager images, title
      
  showSlideshow: (elements) ->
    images = @getImagesFromElements elements
    @ibSlideshow = new Dreamcatcher.Controllers.IbSlideshow $("#slideshow-back") if not @ibSlideshow
    @ibSlideshow.showSlideshow images
    $('#frame.browser').hide()
          
  ## TOP ICON EVENTS
    
  '.top .browseWrap click': (el) ->
    if $("#searchResults").is ':visible'
      @displayScreen el.attr('name'), null
    else
      @displayScreen @currentView, null

  '.top .backArrow click': (el) ->
    @displayScreen el.attr('name'), null

  '.top .searchWrap click': ->
    if not $('.searchFieldWrap').is ':visible'
      $('.browseWrap').attr 'name', @currentView
      @showIcons '.browseWrap, .searchFieldWrap'
  
  '.top .play click': ->
    @showSlideshow $('#albumList .img')
    
  '.top .manage click': ->
    @showManager $("#albumList .img"), @artist


    
  ## VIEW EVENTS
  
  showSpinner: ->
    $("#frame.browser .spinner").show()
  
  hideSpinner: ->
    $("#frame.browser .spinner").hide()
    
    
    
  #- Browse -#

  '#browse .type li click': (el) ->
    $("#browse .type li").removeClass 'selected'
    el.addClass 'selected'
    @section = @type = el.text().trim()
    @categories = el.data('categories').split ','
    $("#categories").replaceWith @view('categories',{ categories: @categories })
  
  '#categories .category click': (el) ->
    @category = el.text().trim()
    @artist = null
    #showSpinner()
    @model.get 'artists', {category: @category, section: @section}, @callback('displayScreen', 'artistList')
    #hidespinner
  
  #- ArtistList -#

  '#artistList tr.artist click': (el) ->
    if $('.artistName',el).attr('readonly')
      @artist = $('.artistName',el).val()
      @model.get 'albums', {artist: @artist, section: @section, category: @category}, @callback('displayScreen', 'albumList')
      
  '#artistList .edit click': (el) ->
    $('.artistName', el.parent()).removeAttr('readonly').focus()
  
  '#artistList .artistName keypress': (el, event) ->
    el.blur().attr('readonly', true) if event.keyCode is 13

    
  
  #- Album List -#
  
  '#albumList .manage click': (el) ->
    tr = el.closest("tr")
    album = tr.data 'album'
    @showManager $('.img',tr.next()), album
  
  '#albumList .images .img img click': (el) ->
    imageId = el.parent().data 'id'
    @showSlides $('.img', el.closest("tr")), imageId
    
  '#albumList .images .add click': (el) ->
    @addImageToDropbox el.parent()
        
  
  
  
  #- SearchResults -#
  '#searchResults li click': (el) ->
    @showSlides $('#searchResults li'), el.data 'id'
  
  #- SearchOptions -#
      
  '.searchField input[type="text"] keypress': (element,event) ->
    @startSearch() if event.keyCode is 13
    return
      
  '.searchField .search click': (el) ->
    @startSearch()
    
  startSearch: ->
    #@showSpinner()
    @model.searchImages @getSearchOptions(), @callback('displaySearchResults')
    
  displaySearchResults: (images) ->
    @displayScreen 'searchResults', @view('searchresults',{ images : images } )
    @setDraggable $("#searchResults ul li")
    @hideSpinner()
    
  '.searchField .options click': (el) ->    
    if not $("#searchOptions").is(":visible")
      @hideAllViews()
      el.addClass 'selected'
      if not @optionsOpened
        $('#searchOptions .type').html @view('searchTypes', {types: @model.types})
        $("#searchOptions .type li").removeClass 'selected'
        $("#searchOptions .type li:contains(#{@type})").click()
        @optionsOpened = true
      $("#searchOptions").show()
    else
      @displayScreen @currentView,null #but keep search header
      @showIcons '.browseWrap, .searchFieldWrap' #todo: refactor
      
  '#searchOptions .type li click': (el) ->
    type = el.text().trim()
    if el.hasClass 'selected'
      el.removeClass 'selected'
      $("#searchOptions .categories div[data-type='#{type}']").remove()
    else
      el.addClass 'selected'
      categories = el.data('categories').split ','
      $('#searchOptions .categories').append @view 'searchCategories', {
        type: type
        categories: categories
      }
      
  '#searchOptions .category click': (el) ->
    if el.hasClass("selected") then el.removeClass("selected") else el.addClass("selected")

  getSearchOptions: ->
    options = {}
    
    searchText = $(".searchField input[type='text']").val().trim()
    options['q'] = searchText  if searchText.length > 0
    
    if $("#searchOptions").is(":visible")
    
      for attr in ['artist','album','title','year','tags']
        val = @getValFromAttr attr
        options[attr] = val if val?
    
      categories = []
      $("#searchOptions .categories .selected").each (i, el) ->
        categories.push $(el).text().trim()
      options['categories'] = genres.join(',') if categories.length > 0
    
    @searchOptions = options
    return options
    
  getValFromAttr: (attr) ->
    inputElement = $("##{attr} input[type='text']");
    val = inputElement.val().trim() if inputElement.val()?
    return val if val.length > 0
    return null

