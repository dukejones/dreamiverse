$.Controller 'Dreamcatcher.Controllers.IbBrowser',

  model: Dreamcatcher.Models.ImageBank
  allViews: ['browse','genreList','artistList','albumList','searchOptions','searchResults','slideshow']
  
  init: ->
    @imageCookie = new Dreamcatcher.Classes.CookieHelper "imagebank"
    @stateCookie = new Dreamcatcher.Classes.CookieHelper "ib_state"
    @restoreState()
    @loadDropbox()
    
    
  ## STATE MANAGEMENT
    
  saveState: (currentView) ->
    state = {
      section: @section
      type: @type
      category: @category
      artist: @artist
      currentView: currentView
    }
    @stateCookie.set JSON.stringify(state)
    log state

  restoreState: ->
    state = JSON.parse @stateCookie.get()
    log state

    if not state?
      @displayScreen "browse",@view('types', { types: @model.types })

    else    
      @section = state.section
      @type = state.type
      @category = state.category
      @artist = state.artist
      
      @showArtistList() if @category?
      @showAlbumList() if @artist?
      
      log state.currentView
      
      @displayScreen state.currentView, null
  
  ## GENERAL DISPLAY
  
  hideAllViews: ->
    for view in @allViews
      @lastView = view if $("##{view}").is(":visible")
    return $( '#'+@allViews.join(', #') ).hide()
    
  showLastView: ->
    @displayScreen @lastView,null if @lastView?
    
  showIcons: (icons) ->
    $(".top,.footer").children().hide()
    $(icons,".top,.footer").show()    

  displayScreen: (type, html) ->
    switch type
      when 'browse'
        @showIcons '.browseHeader, .searchWrap'
        @updateScreen null,null,"#browse",null,html
      when 'artistList'
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
        @showSlide 0
        
    @saveState type

  updateScreen: (previousType, previousName, currentType, currentName, currentHtml) ->
    @hideAllViews()
    
    $(".backArrow .content").text(previousName) if previousName
    $(".backArrow").attr("name",previousType) if previousType
    $("h1").text(currentName) if currentName
    
    $(currentType).replaceWith(currentHtml) if currentHtml?
    $(currentType).show()

          
  ## TOP ICON EVENTS
    
  '.top .browseWrap click': (el) ->
    @showLastView()

  '.top .backArrow click': (el) ->
    @displayScreen el.attr("name"),null

  '.top .searchWrap click': ->
    if not $('.searchFieldWrap').is(':visible')
      @showIcons '.browseWrap, .searchFieldWrap'
  
  '.top .play click': ->
    imageIds = []
    $("#albumList .img").each (index,element) =>
      imageIds.push $(element).data('id')
    
    $(".counter").text("1/"+imageIds.length)    
    @model.findImagesById imageIds.join(','), {}, (images) =>
      @displayScreen 'slideshow', @view('slideshow', { images: images })


    
  ## VIEW EVENTS
    
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
    $.get "/artists?category=#{@category}&section=#{@section}",(html) =>
      @displayScreen "artistList",html
  
  
  #- ArtistList -#
  
  '#artistList td.name click': (el) ->
    @artist = $("h2:first",el).text()
    @showAlbumList()
      
  '#artistList .images img click': (el) ->
    imageId = el.data 'id'
    @showSingleSlide imageId
    
  showAlbumList: ->
    $.get "/albums?artist=#{@artist}&section=#{@section}&category=#{@category}",(html) =>
      @displayScreen "albumList",html
      @setDraggable $("#albumList .images .img")
  
  
      
  #- Album List -#
  
  '#albumList .images .img click': (el) ->
    imageId = el.data 'id'
    @showSingleSlide imageId



  #- Dropbox -#
  
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
  
  loadDropbox: ->
    $("#dropbox .imagelist").html("")
    @showImageInDropbox id for id in @imageCookie.getAll() if @imageCookie.getAll()?
    
    $("#dropbox").droppable {
      drop: (ev, ui) =>
        id = ui.draggable.data('id')
        if not @imageCookie.contains id
          @imageCookie.add id
          @showImageInDropbox id
        else
          alert 'already here'
    }
        
  showImageInDropbox: (imageId, imageMeta) ->
    if imageMeta?
      $("#dropbox .imagelist").append @view('dropboximage',{ image: meta })
    else
      @model.getImage imageId, {}, @callback('showImageInDropbox',imageId)
  
  '#dropbox .cancel click': (el) -> #TODO: fix
    @imageCookie.clear()
    $("#dropbox .imagelist").html("")
  
  
  
    
  #- Slideshow -#

  '.prev click': ->
    currentIndex = $("#slideshow img:visible").index()
    @showSlide currentIndex-1  

  '.next click': ->
    currentIndex = $("#slideshow img:visible").index()
    @showSlide currentIndex+1

  '.add click': (el) ->
    imageElement = $("#slideshow img:visible")
    imageId = imageElement.data('id')
    imageMeta = $("#slideshow img:visible").data('image')
    @imageCookie.add imageId
    @showImageInDropbox imageId,imageMeta
    el.hide()

  showSingleSlide: (imageId) ->
    @model.getImage imageId, {}, (image) =>
      @displayScreen 'slideshow', @view('slideshow', { images: [image] })

  showSlide: (index) ->
    totalCount = $("#slideshow img").length
    index = 0 if index is totalCount
    index = (totalCount-1) if index is -1

    $("#slideshow img").hide()

    imageElement = $("#slideshow img:eq(#{index})")
    imageElement.show()

    imageId = imageElement.data 'id'
    imageMeta = imageElement.data 'image'

    $("h1").text(imageMeta.title)

    if totalCount is 1 then $(".counter,.prev,.next").hide() else $(".counter").text "#{index+1}/#{totalCount}"
    if @imageCookie.contains imageId then $('.add').hide() else $('.add').show()
  
  
  
  
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
      
  '.searchField .search click': (el) ->
    @model.searchImages @getSearchOptions(),@callback('displaySearchResults')
    
  displaySearchResults: (images) ->
    @displayScreen 'searchResults',@view('searchresults',{ images : images } )
    @setDraggable $("#searchResults ul li")

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
    
    return options
    
  getValFromAttr: (attr) ->
    inputElement = $("##{attr} input[type='text']");
    val = inputElement.val().trim() if inputElement.val()?
    return val if val.length > 0
    return null
  

