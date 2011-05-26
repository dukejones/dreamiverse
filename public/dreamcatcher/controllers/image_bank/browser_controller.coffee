$.Controller 'Dreamcatcher.Controllers.ImageBank.Browser',

  ibModel: Dreamcatcher.Models.ImageBank
  imageModel: Dreamcatcher.Models.Image
  
  views: ['browse', 'genreList', 'artistList', 'albumList', 'searchOptions', 'searchResults']
  
  getView: (url, data) ->
    return @view "//dreamcatcher/views/image_bank/browser/#{url}.ejs", data
  
  init: ->
    @showBrowse()
    
  showBrowse: ->
    @displayView 'browse', @getView 'types', { types: @ibModel.types }
  
  show: ->
    @refreshView()
    $('#frame.browser').show()
    
  hideAllViews: ->
    for view in @views
      @lastView = view if $("##{view}").is(':visible') and view isnt 'searchOptions'
      $("##{view}").hide()
    
  showLastView: ->
    @displayView @previous if @previous?
    
  showIcons: (icons) ->
    $(".top,.footer").children().hide()
    $(icons, ".top,.footer").show()
    
  refreshView: ->
    switch @currentView
      when 'browse'
        @showBrowse()
      when 'artist'
        @showArtists()
      when 'albumList'
        @showAlbums()
    
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
        @updateView 'artistList', @category, name, @artist, html
        
        @parent.registerDroppable $('#albumList .images td')
        @parent.registerDraggable $("#albumList .images .img"), false
        
      when 'searchResults'
        @showIcons '.browseWrap, .searchFieldWrap, .drag'
        @updateView null, null, name, null, html
        
    @currentView = name    

  updateView: (previousElement, previousName, currentElement, currentName, html) ->
    
    # update head
    backArrow = $(".backArrow") 
    backArrow.attr 'name', previousElement if previousElement?
    
    $(".content span", backArrow).text previousName if previousName?
    $('.content .img', backArrow).toggle(previousName is 'browse')
    $('#frame.browser h1').text currentName if currentName

    @hideAllViews()

    $("##{currentElement}").replaceWith html if html?
    $("##{currentElement}").show()

  ## TOP ICON EVENTS
    
  '.top .browseWrap click': (el) ->
    if $("#searchResults").is ':visible'
      @displayView @previousView, null
    else
      @displayView @currentView, null

  '.top .backArrow click': (el) ->
    @displayView el.attr('name'), null

  '.top .searchWrap click': ->
    if not $('.searchFieldWrap').is ':visible'
      $('.browseWrap').attr 'name', @currentView
      @showIcons '.browseWrap, .searchFieldWrap'
  
  '.top .play click': ->
    @parent.showSlideshow 'artist'
    
  '.top .manage click': ->
    @parent.showManager 'artist', @artist


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
    $("#categories").replaceWith @getView 'categories', { categories: @categories }
  
  
  '#categories .category click': (el) ->
    @category = el.text().trim()
    @artist = null
    @showArtists()

  showArtists: ->
    @ibModel.getHtml 'artists', {category: @category, section: @section}, (html) =>
      @displayView 'artistList', html
  
  #- ArtistList -#

  '#artistList tr.artist click': (el) ->
    return if not $('.artistName',el).attr 'readonly'
    @artist = $('.artistName',el).val()
    @showAlbums()
    
  showAlbums: ->
     @ibModel.getHtml 'albums', {artist: @artist, section: @section, category: @category}, (html) =>
        @displayView 'albumList', html
    
  #- Album List -#
  
  '#albumList .manage click': (el) ->
    tr = el.closest 'tr'
    album = tr.data 'album'
    @parent.showManager 'album', album, album
  
  '#albumList .images .img img click': (el) ->
    tr = el.closest 'tr'
    album = tr.data 'album'
    imageId = el.parent().data 'id'
    @parent.showSlideshow 'album', imageId, album
    
  '#albumList .images .add click': (el) ->
    @parent.addImageToDropbox el.parent()
    
  '.edit mouseover': (el) ->
    $('.editable', el.parent()).addClass 'hover'

  '.edit mouseout': (el) ->
    editable = $('.editable', el.parent())
    editable.removeClass 'hover' if not editable.is(':focus')

  '.edit click': (el) ->
    editable = $('.editable', el.parent())
    editable.removeAttr 'readonly'
    editable.addClass 'hover'
    editable.focus()

  '.editable keypress': (el, event) ->
    if event.keyCode is 13
      el.attr 'readonly', true
      el.blur()
      el.removeClass 'hover'
      @updateField el 
    
  updateField: (el) ->
    field = el.closest('table').attr('id').replace('List','')
    newValue = el.val()
    oldValue = el.closest('tr').data field
    
    #log newValue
    
    image = {}
    image[field] = newValue
    if field is 'album'      
      $("#albumList tr.images[data-album='#{oldValue}'] .img").each (i, el) =>
        imageId = $(el).data 'id'
        @imageModel.update imageId, {image: image }
        @refreshView()
        
    else if field is 'artist'
      alert 'cannot update this!'
      el.val oldValue
      
  #- SearchResults -#
  
  '.searchField input[type="text"] keypress': (el, ev) ->
    $('.searchField .search').click() if ev.keyCode is 13

  '.searchField .search click': (el) ->
    @imageModel.search @parent.getSearchOptions(), (images) =>
      @displayView 'searchResults', @getView('searchresults',{ images : images } )
      @parent.registerDraggable $("#searchResults ul li")
  
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
    @parent.showSlideshow 'searchResults', el.data 'id'
