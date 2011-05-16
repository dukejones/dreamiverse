$.Controller 'Dreamcatcher.Controllers.IbBrowser',

  model: Dreamcatcher.Models.ImageBank
  allViews: ['browse','genreList','artistList','albumList','searchOptions','searchResults','slideshow','infoTags']
  
  init: ->
    @imageCookie = new Dreamcatcher.Classes.CookieHelper "ib_dropbox"
    #@stateCookie = new Dreamcatcher.Classes.CookieHelper "ib_state"
    @displayScreen "browse", @view('types', { types: @model.types })
    #@loadDropbox()
    
    $(document).keyup (event) ->
      if event.keyCode is 37
        $(".footer .prev").click() if $(".footer .prev").is(":visible")
      if event.keyCode is 39
        $(".footer .next").click() if $(".footer .next").is(":visible")
      
  ## DROPBOX ##
  
  loadDropbox: ->
    #clear dropbox
    $('#dropbox .imagelist').html ''
    
    #shows all images in dropbox
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
      #stop: =>
    }

  #new: refactor
  setDraggable: (el, fromDropbox) ->
    if fromDropbox
      el.draggable {
        containment: 'document'
        helper: 'clone'
        zIndex: 100
        start: ->
          $("#dropbox").css('z-index',1200)
          $("#bodyClick").show()
        stop: ->
          $("#dropbox").css('z-index','')
          $("#bodyClick").hide()
      }
    else
      el.draggable {
        containment: 'document'
        helper: 'clone'
        zIndex: 100
        start: ->
          $("#dropbox .active").show()
        stop: ->
          $("#dropbox .active").hide()
      }
  
    ###
    el.draggable {
      containment: 'document'
      helper: 'clone'
      zIndex: 100
      start: ->
        if fromDropbox
          $("#dropbox").css('z-index',1200)
          $("#bodyClick").show()
        else
          $("#dropbox .active").show()
      stop: ->
        if fromDropbox
          $("#dropbox").css('z-index','')
          $("#bodyClick").hide()
        else
          $("#dropbox .active").hide()
      ###

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
    
  '#dropbox .edit click': (el) ->
    @showManager $('#dropbox li')
    
  '#dropbox li .close click': (el) ->
    @removeImageFromDropbox el.parent()


  
  
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
        @setDraggable $("#albumList .images .img"), false
        
      when 'searchResults'
        @showIcons '.browseWrap, .searchFieldWrap, .drag'
        @updateScreen null, null, '#searchResults', null, html
        
      when 'slideshow'
        @showIcons '.backArrow, h1, .counter, .prev, .info, .tag, .add, .next, .edit, .cancel'
        if @artist?
          @updateScreen 'albumList', @artist, '#slideshow', 'slideshow', html
        else
          @updateScreen 'artistList', @category, '#slideshow', 'slideshow', html
        #todo: different one for search
        
    @currentView = type

  updateScreen: (previousType, previousName, currentType, currentName, currentHtml, show) ->
    @hideAllViews()
    
    $(".backArrow .content span").text(previousName) if previousName
    if previousName is 'browse' then $('.backArrow .content .img').show() else $('.backArrow .content .img').hide()
    $('.backArrow').attr('name',previousType) if previousType
    $('h1').text(currentName) if currentName
    $(currentType).replaceWith(currentHtml) if currentHtml?
    $(currentType).show()
    
  showManager: (elements) ->
    images = []
    elements.each (i,el) =>
      images[i] = $(el).data 'image'
    
    if not $('#frame.manager').exists()
      $.get '/images/manage', (html) =>
        $('#frame.browser').hide().after html
        @ibManager = new Dreamcatcher.Controllers.IbManager $("#frame.manager") if not @ibManager
        @ibManager.showManager images
    else
      $('#frame.browser').hide()
      @ibManager.showManager images
          
  ## TOP ICON EVENTS
    
  '.top .browseWrap click': (el) ->
    if $("#searchResults").is ':visible'
      @showLastView()
    else
      @displayScreen @currentView, null

  '.top .backArrow click': (el) ->
    @displayScreen el.attr('name'), null

  '.top .searchWrap click': ->
    if not $('.searchFieldWrap').is ':visible'
      @showIcons '.browseWrap, .searchFieldWrap'
  
  '.top .play click': ->
    @showAlbumSlides 0
    
  '.top .manage click': ->
    @showManager $("#albumList .img")


    
  ## VIEW EVENTS
  
  showSpinner: ->
    $("#frame.browser .spinner").show()
  
  hideSpinner: ->
    $("#frame.browser .spinner").hide()
    
  #- Browse -#

  '#type li click': (el) ->
    $("#type li").removeClass 'selected'
    el.addClass 'selected'
    @section = @type = el.text().trim()
    @categories = el.data('categories').split ','
    $("#categories").replaceWith @view('categories',{ categories: @categories })
  
  '#categories .category click': (el) ->
    @category = el.text().trim()
    @artist = null
    #@showSpinner()
    @model.getArtists {category: @category, section: @section}, @callback('displayScreen', 'artistList')
    #hidespinner
  
  #- ArtistList -#

  '#artistList tr.artist click': (el) ->
    @artist = $("h2:first",el).text()
    @model.getAlbums {artist: @artist, section: @section, category: @category}, @callback('displayScreen', 'albumList')
      
  
  #- Album List -#
  
  '#albumList .manage click': (el) ->
    @showManager $('.img',el.closest("tr").next())
  
  '#albumList .images .img img click': (el) ->
    imageId = el.parent().data 'id'
    album = el.closest("tr").data 'album'
    @showAlbumSlides imageId,album
    
  '#albumList .images .add click': (el) ->
    @addImageToDropbox el.parent()
        
  #- Slideshow -#

  '.footer .prev click': ->
    currentIndex = $("#slideshow .img:visible").index()
    @showSlide currentIndex - 1  

  '.footer .next click': ->
    currentIndex = $("#slideshow .img:visible").index()
    @showSlide currentIndex + 1

  ###
  '.footer .add click': (el) ->
    imageElement = $("#slideshow img:visible")
    imageId = imageElement.data 'id' 
    imageMeta = imageElement.data 'image'  #todo: refactor?
    @imageCookie.add imageId
    @showImageInDropbox imageId,imageMeta
    el.hide()
  ###
    
  showInfo: (meta) ->
    $("#info .name span").text meta.title
    $("#info .author span").text meta.artist
    $("#info .year span").text meta.year
  
  showTags: (meta) ->
    #todo
    
  showInfoTag: (type) ->
    $("#infoTags").show() if not $("#infoTags").is(':visible')
    target = $("##{type}")
    if target.is(":visible") 
      target.hide() 
    else
      meta = $("#slideshow .img:visible:first").data 'image'
      @showTags meta if type is 'tagging'
      @showInfo meta if type is 'info'
      target.show()  
    
  '.footer .info click': ->
    @showInfoTag 'info'
  
  '.footer .tag click': ->
    @showInfoTag 'tagging'
        
  showAlbumSlides: (imageId, album) ->
    #todo: refactor so there's no need for ajax call
    imageIds = []
    index = 0
    albumSelector = if album? then "tr[data-album='#{album}']"  else ""
    $("#albumList #{albumSelector} .img").each (i, el) =>
      id = $(el).data 'id'
      imageIds[i] = id
      index = i if id is imageId
    @model.findImagesById imageIds.join(','), {}, (images) =>
      #this loads the html first, before it displays the slideshow
      $("#slideshow").replaceWith @view('slideshow', { images: images })
      @showSlide index #todo: only show once slide displayed
      @displayScreen 'slideshow',null
      @setDraggable $('#slideshow .img')

  showSingleSlide: (imageId) ->
    @model.getImage imageId, {}, (image) =>
      @displayScreen 'slideshow', @view('slideshow', { images: [image] })
      @showSlide 0

  showSlide: (index) ->
    totalCount = $("#slideshow .img").length
    index = 0 if index is totalCount
    index = (totalCount-1) if index is -1

    $("#slideshow .img").hide()

    imageElement = $("#slideshow .img:eq(#{index})")
    imageElement.show()

    imageId = imageElement.data 'id'
    imageMeta = imageElement.data 'image'

    $("h1").text imageMeta.title
    @showInfo imageMeta

    if totalCount is 1 then $(".counter,.prev,.next").hide() else $(".counter").text "#{index+1}/#{totalCount}"
    # todo: look at add buttons etc
    # if @imageCookie.contains imageId then $('.add').hide() else $('.add').show()
    
  '#slideshow .add click': (el) ->
    @addImageToDropbox el.parent()
  
  
  #- SearchResults -#
  '#searchResults li click': (el) ->
    imageId = el.data 'id'
    @showSingleSlide imageId #todo: check repeated
  
  #- SearchOptions -#
  
  '.searchField .options click': (el) ->    
    if not $("#searchOptions").is(":visible")
      @hideAllViews()
      el.addClass("selected")
      $('#searchOptions .category select').append("<option>#{category}</option>") for category in @categories if @categories
      $("#searchOptions .genres").html @view('genres', { genres: @model.genres })
      $("#searchOptions").show()
    else
      @displayScreen @currentView,null #but keep search header
      @showIcons '.browseWrap, .searchFieldWrap' #todo: refactor
      
  '.searchField input[type="text"] keypress': (element,event) ->
    @startSearch() if event.keyCode is 13
    return
      
  '.searchField .search click': (el) ->
    @startSearch()
    
  startSearch: ->
    @showSpinner()
    @model.searchImages @getSearchOptions(),@callback('displaySearchResults')
    
  displaySearchResults: (images) ->
    @displayScreen 'searchResults',@view('searchresults',{ images : images } )
    @setDraggable $("#searchResults ul li")
    @hideSpinner()

  '#searchOptions .genre click': (el) ->
    if el.hasClass("selected") then el.removeClass("selected") else el.addClass("selected")
    
  getSearchOptions: ->
    options = {}
    
    #searchtext
    searchText = $(".searchField input[type='text']").val().trim()
    options['q'] = searchText  if searchText.length > 0
    
    if $("#searchOptions").is(":visible")
      #attributes - artist, album etc
      for attr in ['artist','album','title','year','tags']
        val = @getValFromAttr attr
        options[attr] = val if val?
      #genres
      genres = []
      $(".genre.selected").each (index,element) ->
        genres.push $(element).text().trim()
      options['genres'] = genres.join(',') if genres.length > 0
    
    @searchOptions = options
    return options
    
  getValFromAttr: (attr) ->
    inputElement = $("##{attr} input[type='text']");
    val = inputElement.val().trim() if inputElement.val()?
    return val if val.length > 0
    return null

