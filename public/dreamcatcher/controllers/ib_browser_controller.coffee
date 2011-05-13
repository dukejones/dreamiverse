$.Controller 'Dreamcatcher.Controllers.IbBrowser',

  model: Dreamcatcher.Models.ImageBank
  allViews: ['browse','genreList','artistList','albumList','searchOptions','searchResults','slideshow','infoTags']
  
  init: ->
    @imageCookie = new Dreamcatcher.Classes.CookieHelper "ib_dropbox"
    @stateCookie = new Dreamcatcher.Classes.CookieHelper "ib_state"
    @displayScreen "browse",@view('types', { types: @model.types })
    
    #@managerShow = 'dropbox' #dropbox, album, artist
    @loadDropbox()
    @restoreState()
    
    $(document).keyup (event) ->
      if event.keyCode is 37
        $(".footer .prev").click() if $(".footer .prev").is(":visible")
      if event.keyCode is 39
        $(".footer .next").click() if $(".footer .next").is(":visible")
    
    
  ## STATE MANAGEMENT
    
  saveState: () ->
    state = {
      section: @section
      type: @type
      category: @category
      artist: @artist
      searchOptions: @searchOptions
      currentView: @currentView
      manageShow: @manageShow
      
      dropbox: $("#dropbox").offset()
    }
    @stateCookie.set JSON.stringify(state)

  restoreState: ->
    state = JSON.parse @stateCookie.get()
    if state?    
      @section = state.section
      @type = state.type
      @category = state.category
      @artist = state.artist
      
      @showArtistList() if @category?
      @showAlbumList() if @artist?
      
      $("#dropbox").offset state.dropbox if state.dropbox
      
      @displayScreen state.currentView, null
      
      
  ## DROPBOX ##
  
  loadDropbox: ->
    $("#dropbox .imagelist").html("")
    @showImageInDropbox id for id in @imageCookie.getAll() if @imageCookie.getAll()?

    $("#dropbox").droppable {
      drop: (ev, ui) =>
        @addImageToDropbox ui.draggable
    }
    $("#dropbox").draggable {
      stop: =>
        @saveState()
    }

  setDraggable: (el) ->
    el.draggable {
      containment: 'document'
      helper: 'clone'
      zIndex: 100
      start: ->
        $("#dropbox .active").show()
      stop: ->
        $("#dropbox .active").hide()
    }

  addImageToDropbox: (el) ->
    imageId = el.data 'id'
    imageMeta = el.data 'image'
    if not @imageCookie.contains imageId
      @imageCookie.add imageId
      @showImageInDropbox imageId,imageMeta
    else
      alert 'already here' #todo - something better

  showImageInDropbox: (imageId, imageMeta) ->
    if imageMeta?
      $("#dropbox .imagelist").append @view('dropboximage',{ image: imageMeta })
    else
      @model.getImage imageId, {}, @callback('showImageInDropbox', imageId)  
      
  '#dropbox .cancel click': (el) -> #TODO: fix
    @imageCookie.clear()
    $("#dropbox .imagelist").html("")
    
  '#dropbox .edit click': (el) ->
    @showManager 'dropbox'
    
  '#dropbox li .close click': (el) ->
    imageId = el.parent().data 'id'
    @imageCookie.remove imageId
    el.parent().remove()


  
      
  
  ## GENERAL DISPLAY
  
  hideAllViews: ->
    for view in @allViews
      @lastView = view if $("##{view}").is(":visible") and view isnt 'searchOptions'
    return $( '#'+@allViews.join(', #') ).hide()
    
  showLastView: ->
    @displayScreen @lastView,null if @lastView?
    
  showIcons: (icons) ->
    $(".top,.footer").children().hide()
    $(icons,".top,.footer").show()    

  displayScreen: (type, html) ->
    switch type
      when 'browse'
        @category = null
        @showIcons '.browseHeader, .searchWrap'
        @updateScreen null,null,"#browse",null,html
      when 'artistList'
        @artist = null
        @showIcons '.backArrow, h1, .searchWrap'
        @updateScreen "browse",'browse',"#artistList",@category,html
      when 'albumList'
        @showIcons '.backArrow, h1, .play, .manage, .searchWrap, .drag'
        @updateScreen "artistList",@category,"#albumList",@artist,html
      when 'searchResults'
        @showIcons '.browseWrap, .searchFieldWrap, .drag'
        @updateScreen null,null,'#searchResults',null,html
      when 'slideshow'
        @showIcons '.backArrow, h1, .counter, .prev, .info, .tag, .add, .next, .edit, .cancel'
        if @artist?
          @updateScreen 'albumList',@artist,'#slideshow','slideshow',html
        else
          @updateScreen 'artistList',@category,'#slideshow','slideshow',html
        #todo: different one for search
        
    @currentView = type
    @saveState()

  updateScreen: (previousType, previousName, currentType, currentName, currentHtml, show) ->
    @hideAllViews()
    
    $(".backArrow .content").text(previousName) if previousName
    $(".backArrow").attr("name",previousType) if previousType
    $("h1").text(currentName) if currentName
    
    $(currentType).replaceWith(currentHtml) if currentHtml?
    $(currentType).show()
    
  showManager: (manageShow) ->
    @manageShow = manageShow
    @saveState()
    
    if not $("#frame.manager").exists()
      $.get '/images/manage',(html) =>
        $('#frame.browser').hide().after html
        @ibManager = new Dreamcatcher.Controllers.IbManager $("#frame.manager") if not @ibManager
        @ibManager.showManager()
    else
      $('#frame.browser').hide()
      @ibManager.showManager()
          
  ## TOP ICON EVENTS
    
  '.top .browseWrap click': (el) ->
    @showLastView()

  '.top .backArrow click': (el) ->
    @displayScreen el.attr("name"),null

  '.top .searchWrap click': ->
    if not $('.searchFieldWrap').is(':visible')
      @showIcons '.browseWrap, .searchFieldWrap'
  
  '.top .play click': ->
    @showAlbumSlides 0
    
  '.top .manage click': ->
    @showManager 'artist'


    
  ## VIEW EVENTS
  
  showSpinner: ->
    $("#frame.browser .spinner").show()
  
  hideSpinner: ->
    $("#frame.browser .spinner").hide()
    
  #- Browse -#

  '#type li click': (el) ->
    $("#type li").removeClass('selected')
    el.addClass('selected')
    @section = @type = el.text().trim()
    @categories = el.data('categories').split(',')
    $("#categories").replaceWith @view('categories',{ categories: @categories })
  
  '#categories .category click': (el) ->
    @category = el.text().trim()
    @artist = null
    @showArtistList()
      
  showArtistList: ->
    @showSpinner()
    $.get "/artists?category=#{@category}&section=#{@section}",(html) =>
      @displayScreen "artistList",html
      @hideSpinner()
  
  
  #- ArtistList -#
  
  '#artistList td.name click': (el) ->
    @artist = $("h2:first",el).text()
    @showAlbumList()
      
  '#artistList .images img click': (el) ->
    imageId = el.data 'id'
    @showSingleSlide imageId
    
  showAlbumList: ->
    @showSpinner()
    $.get "/albums?artist=#{@artist}&section=#{@section}&category=#{@category}",(html) =>
      @displayScreen "albumList",html
      @setDraggable $("#albumList .images .img")
      @hideSpinner()
      
  
  #- Album List -#
  
  '#albumList .manage': (el) ->#fix
    @album = el.closest("tr").data 'album'
    @showManager 'album'
  
  '#albumList .images .img img click': (el) ->
    imageId = el.parent().data 'id'
    album = el.closest("tr").data 'album'
    @showAlbumSlides imageId,album
    
  '#albumList .images .add click': (el) ->
    @addImageToDropbox el.parent()
        
  #- Slideshow -#

  '.footer .prev click': ->
    currentIndex = $("#slideshow img:visible").index()
    @showSlide currentIndex-1  

  '.footer .next click': ->
    currentIndex = $("#slideshow img:visible").index()
    @showSlide currentIndex+1

  '.footer .add click': (el) ->
    imageElement = $("#slideshow img:visible")
    imageId = imageElement.data('id')
    imageMeta = imageElement.data('image') #todo: refactor?
    @imageCookie.add imageId
    @showImageInDropbox imageId,imageMeta
    el.hide()
    
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
      meta = $("#slideshow img:visible:first").data 'image'
      if type is 'tagging' #todo: refactor?
        @showTags meta
        $('#info').hide()
      else if type is 'info'
        @showInfo meta
        $('#tagging').hide()
      target.show()  
    
  '.footer .info click': ->
    @showInfoTag 'info'
  
  '.footer .tag click': ->
    @showInfoTag 'tagging'
        
  showAlbumSlides: (imageId, album) ->
    imageIds = []
    index = 0
    albumSelector = if album? then "tr[data-album='#{album}']"  else ""
    $("#albumList #{albumSelector} .img").each (i, el) =>
      id = $(el).data 'id'
      imageIds[i] = id
      index = i if id is imageId
    #$(".counter").text("1/"+imageIds.length)    
    @model.findImagesById imageIds.join(','), {}, (images) =>
      #this loads the html first, before it displays the slideshow
      $("#slideshow").replaceWith @view('slideshow', { images: images })
      @showSlide index #todo: only show once slide displayed
      @displayScreen 'slideshow',null

  showSingleSlide: (imageId) ->
    @model.getImage imageId, {}, (image) =>
      @displayScreen 'slideshow', @view('slideshow', { images: [image] })
      @showSlide 0

  showSlide: (index) ->
    totalCount = $("#slideshow img").length
    index = 0 if index is totalCount
    index = (totalCount-1) if index is -1

    $("#slideshow img").hide()

    imageElement = $("#slideshow img:eq(#{index})")
    imageElement.show()

    imageId = imageElement.data 'id'
    imageMeta = imageElement.data 'image'

    title = imageMeta.title
    #album = imageMeta.album
    #album = " / "+album if album.length > 0
    header = title #+ album
    $("h1").text(title)
    @showInfo imageMeta

    if totalCount is 1 then $(".counter,.prev,.next").hide() else $(".counter").text "#{index+1}/#{totalCount}"
    if @imageCookie.contains imageId then $('.add').hide() else $('.add').show()
  
  
  #- SearchResults -#
  '#searchResults li click': (el) ->
    imageId = el.data 'id'
    @showSingleSlide imageId #todo: check repeated
  
  #- SearchOptions -#
  
  '.searchField .options click': (el) ->    
    if not $("#searchOptions").is(":visible")
      @hideAllViews()
      el.addClass("selected")
      $('#searchOptions .category select').append("<option>#{category}</option>") for category in @categories
      $("#searchOptions .genres").html @view('genres',{genres: @model.genres})
      $("#searchOptions").show()
    else
      @showLastView()
      
  '.searchField input[type="text"] keypress': (element,event) ->
    @startSearch() if event.keyCode is 13 #enter press
      
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

