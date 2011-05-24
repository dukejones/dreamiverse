$.Controller 'Dreamcatcher.Controllers.IbBrowser',

  model: Dreamcatcher.Models.ImageBank
  views: ['browse', 'genreList', 'artistList', 'albumList', 'searchOptions', 'searchResults']
  current: {}
  previous: {}
  
  init: ->
    html = @view 'types', { types: @model.types }
    @displayView 'browse', html
  
  show: ->
    $('#frame.browser').show()
    
  hideAllViews: ->
    @lastView = view if $("##{view}").is ':visible' and view isnt 'searchOptions' for view in @views
    selector = @views.join ', #'
    return $("##{selector}").hide()
    
  showLastView: ->
    @displayScreen @previous if @previous?
    
  showIcons: (icons) ->
    $(".top,.footer").children().hide()
    $(icons, ".top,.footer").show()    
    
  displayView: (name, html) ->
    
    switch name
    
      when 'browse'
        @category = null
        @showIcons '.browseHeader, .searchWrap'
        @updateView null, null, name, null, html
        
      when 'artistList'
        @artist = null
        @showIcons '.backArrow, h1, .searchWrap'
        @updateView 'browse', 'browse', name, @category, html
        
      when 'albumList'
        @showIcons '.backArrow, h1, .play, .manage, .searchWrap, .drag'
        @updateScreen 'artistList', @category, name, @artist, html
        
        @parent.registerDroppable $('#albumList .images td')
        @parent.registerDraggable $("#albumList .images .img"), false
        
      when 'searchResults'
        @showIcons '.browseWrap, .searchFieldWrap, .drag'
        @updateScreen null, null, name, null, html
        
    @current.view = name    

  updateScreen: (previousName, previouscurrentName, currentElement, html, show) ->
    
    # update head
    backArrow = $(".backArrow .content") 
    $("span", backArrow).text previousName if previousName?
    $('.img', backArrow).toggle previousName is 'browse'
    $('#frame.browser h1').text currentName if current.name
    
    @hideAllViews()
    
    # update current view
    $(currentElement).replaceWith html if html?
    $(currentElement).show()
    
          
  ## TOP ICON EVENTS
    
  '.top .browseWrap click': (el) ->
    if $("#searchResults").is ':visible'
      @displayScreen @previous.name, null
    else
      @displayScreen @current.view, null

  '.top .backArrow click': (el) ->
    @displayScreen el.attr('name'), null

  '.top .searchWrap click': ->
    if not $('.searchFieldWrap').is ':visible'
      $('.browseWrap').attr 'name', @currentView
      @showIcons '.browseWrap, .searchFieldWrap'
  
  '.top .play click': ->
    @parent.showSlideshow $('#albumList .img')
    
  '.top .manage click': ->
    @parent.showManager $("#albumList .img"), @artist


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
    $("#categories").replaceWith @view 'categories', { categories: @categories }
  
  
  '#categories .category click': (el) ->
    @category = el.text().trim()
    @artist = null
    @model.getHtml 'artists', {category: @category, section: @section}, (html) =>
      @displayScreen 'artistList', html    
  
  
  #- ArtistList -#

  '#artistList tr.artist click': (el) ->
    return if not $('.artistName',el).attr 'readonly'
    
    @artist = $('.artistName',el).val()
    @model.getHtml 'albums', {artist: @artist, section: @section, category: @category}, (html) =>
      @displayScreen 'albumList', html
      
  '#artistList .edit mouseover': (el) ->
    $('.artistName', el.parent()).addClass 'hover'
    
  '#artistList .edit mouseout': (el) ->
    artistName = $('.artistName', el.parent())
    artistName.removeClass 'hover' if not artistName.is(':focus')
      
  '#artistList .edit click': (el) ->
    artistName = $('.artistName', el.parent())
    artistName.removeAttr 'readonly'
    artistName.focus()
  
  '#artistList .artistName keypress': (el, event) ->
    el.blur() if event.keyCode is 13
  
  '#artistList .artistName blur': (el) ->
    el.attr 'readonly', true
    el.removeClass 'hover'

    
  #- Album List -#
  
  '#albumList .manage click': (el) ->
    tr = el.closest 'tr'
    album = tr.data 'album'
    @parent.showManager $('.img', tr.next()), album
  
  '#albumList .images .img img click': (el) ->
    @parent.showSlideshow $('.img', el.closest 'tr'), el.parent().index()
    
  '#albumList .images .add click': (el) ->
    @parent.addImageToDropbox el.parent()
    
    
  #- SearchResults -#
  
  '.searchField input[type="text"] keypress': (el, ev) ->
    $('.searchField .search').click() if ev.keyCode is 13

  '.searchField .search click': (el) ->
    @model.searchImages @getSearchOptions(), (images) =>
      @displayScreen 'searchResults', @view('searchresults',{ images : images } )
      @parent.registerDraggable $("#searchResults ul li")
      
  '.spinner click': (el)
    $('.spinner').show()
  
  '.searchField .options click': (el) ->    
    if not $('#searchOptions').is ':visible'
      @hideAllViews()
      el.addClass 'selected'
      @parent.showSearchOptions()
    else
      el.removeClass 'selected'
      @displayView @currentView
      @showIcons '.browseWrap, .searchFieldWrap'
  
  '#searchResults li click': (el) ->
    @parent.showSlideshow $('#searchResults li'), el.data 'id'
