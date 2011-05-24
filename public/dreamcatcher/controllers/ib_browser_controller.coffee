$.Controller 'Dreamcatcher.Controllers.IbBrowser',

  model: Dreamcatcher.Models.ImageBank
  
  init: ->
    @displayScreen 'browse', @view 'types', { types: @model.types }
    
  show: ->
    $('#frame.browser').show()
    
  getSearchOptions: ->
    options = @parent.getSearchOptions()
    searchText = $(".searchField input[type='text']").val().trim()
    options['q'] = searchText  if searchText.length > 0
    return options
  
  allViews: ['browse', 'genreList', 'artistList', 'albumList', 'searchOptions', 'searchResults']
  
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
        @parent.registerDroppable $('#albumList .images td')
        @parent.registerDraggable $("#albumList .images .img"), false
        
      when 'searchResults'
        @showIcons '.browseWrap, .searchFieldWrap, .drag'
        @updateScreen null, null, '#searchResults', null, html
        
    @currentView = type
    
    

  updateScreen: (previousType, previousName, currentType, currentName, currentHtml, show) ->
    @hideAllViews()
    
    $(".backArrow .content span").text(previousName) if previousName
    if previousName is 'browse' then $('.backArrow .content .img').show() else $('.backArrow .content .img').hide()
    $('.backArrow').attr 'name', previousType if previousType
    $('#frame.browser h1').text currentName if currentName
    $(currentType).replaceWith currentHtml if currentHtml?
    $(currentType).show()
    
          
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
    tr = el.closest("tr")
    album = tr.data 'album'
    @parent.showManager $('.img',tr.next()), album
  
  '#albumList .images .img img click': (el) ->
    @parent.showSlideshow $('.img', el.closest("tr")), el.parent().index()
    
  '#albumList .images .add click': (el) ->
    @parent.addImageToDropbox el.parent()
    
    
  #- SearchResults -#
  
  '.searchField input[type="text"] keypress': (element,event) ->
    $('.searchField .search').click() if event.keyCode is 13
    return

  '.searchField .search click': (el) ->
    #@showSpinner()
    @model.searchImages @getSearchOptions(), (images) =>
      @displayScreen 'searchResults', @view('searchresults',{ images : images } )
      @parent.registerDraggable $("#searchResults ul li")
      #@hideSpinner()
  
  '.searchField .options click': (el) ->    
    if not $("#searchOptions").is(":visible")
      @hideAllViews()
      el.addClass 'selected'
      @parent.showSearchOptions()
    else
      el.removeClass 'selected'
      @displayScreen @currentView,null #but keep search header
      @showIcons '.browseWrap, .searchFieldWrap' #todo: refactor
  
  '#searchResults li click': (el) ->
    @parent.showSlideshow $('#searchResults li'), el.data 'id'
        
  
  
  
  
