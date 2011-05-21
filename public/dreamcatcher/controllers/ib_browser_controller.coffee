$.Controller 'Dreamcatcher.Controllers.IbBrowser',

  model: Dreamcatcher.Models.ImageBank
  
  init: ->
    @displayScreen "browse", @view('types', { types: @model.types })
    @showDropbox()
    


  showDropbox: ->
    @ibDropbox = new Dreamcatcher.Controllers.IbDropbox $("#dropbox") if not @ibDropbox
    @ibDropbox.ibBrowser = this
    @ibDropbox.show()

  showManager: (elements, title) ->
    images = @getImagesFromElements elements

    if not $('#frame.manager').exists()
      $.get '/images/manage', (html) =>
        $('#frame.browser').hide().after html
        @ibManager = new Dreamcatcher.Controllers.IbManager $("#frame.manager") if not @ibManager?
        @ibManager.show images, title
    else
      $('#frame.browser').hide()
      @ibManager.show images, title

  showSlideshow: (elements, index) ->
    images = @getImagesFromElements elements
    @ibSlideshow = new Dreamcatcher.Controllers.IbSlideshow $("#slideshow-back") if not @ibSlideshow?
    @ibSlideshow.show images, index
    $('#frame.browser').hide()
    
  showSearchOptions: ->
    @ibSearchOptions = new Dreamcatcher.Controllers.IbSearchOptions $("#searchOptions") if not @ibSearchOptions?
    @ibSearchOptions.show()
    
    
    
  getSearchOptions: ->
    options = {}
    options = @ibSearchOptions.get() if @ibSearchOptions?
    
    searchText = $(".searchField input[type='text']").val().trim()
    options['q'] = searchText  if searchText.length > 0
    
    return options
    
      
    
  
  allViews: ['browse', 'genreList', 'artistList', 'albumList', 'searchOptions', 'searchResults', 'slideshow-back']
  
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
        
        @ibDropbox.registerDroppable $('#albumList .images td')
        @ibDropbox.registerDraggable $("#albumList .images .img"), false
        
      when 'searchResults'
        @showIcons '.browseWrap, .searchFieldWrap, .drag'
        @updateScreen null, null, '#searchResults', null, html
        
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
    @showSlideshow $('.img', el.closest("tr")), el.parent().index()
    
  '#albumList .images .add click': (el) ->
    @addImageToDropbox el.parent()
    
    
    
  #- SearchResults -#
  
  
  '.searchField input[type="text"] keypress': (element,event) ->
    $('.searchField .search').click() if event.keyCode is 13
    return

  '.searchField .search click': (el) ->
    #@showSpinner()
    @model.searchImages @getSearchOptions(), (images) =>
      @displayScreen 'searchResults', @view('searchresults',{ images : images } )
      @ibDropbox.registerDraggable $("#searchResults ul li")
      #@hideSpinner()
  
  '.searchField .options click': (el) ->    
    if not $("#searchOptions").is(":visible")
      @hideAllViews()
      el.addClass 'selected'
      @showSearchOptions()
    else
      el.removeClass 'selected'
      @displayScreen @currentView,null #but keep search header
      @showIcons '.browseWrap, .searchFieldWrap' #todo: refactor
  
  '#searchResults li click': (el) ->
    @showSlideshow $('#searchResults li'), el.data 'id'
        
  
  
  
  
