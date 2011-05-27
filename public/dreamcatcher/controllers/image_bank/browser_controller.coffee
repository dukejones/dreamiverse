$.Controller 'Dreamcatcher.Controllers.ImageBank.Browser',

  ibModel: Dreamcatcher.Models.ImageBank
  imageModel: Dreamcatcher.Models.Image
  
  
  #- gets a specific browser view
  getView: (url, data) ->
    return @view "//dreamcatcher/views/image_bank/browser/#{url}.ejs", data
  
  #- constructor
  init: ->
    @showBrowse()
    
  getState: ->
    {
      type: @type
      category: @category
      artist: @artist
    }
    
  #- shows the browser, and refreshes the current view
  show: (refresh) ->
    @refreshView() if refresh
    $('#frame.browser').show()
    
  #- hides all the views, and saves the previous view
  hideAllViews: ->
    for view in ['browse', 'artistList', 'albumList', 'searchResults']
      @previousView = view if $("##{view}").is(':visible')
      $("##{view}").hide()
    
  #- show the previous view
  showPreviousView: ->
    @displayView @previousView if @previousView?
    
  #- shows only the specified icons
  showIcons: (icons) ->
    $(".top,.footer").children().hide()
    $(icons, ".top,.footer").show()
    
  #- refreshes the current view (usually if the underlying model has changed)
  refreshView: ->
    switch @currentView
      when 'browse'
        @showBrowse()
      when 'artist'
        @showArtists()
      when 'albumList'
        @showAlbums()
        
  #- show the browse view
  showBrowse: ->
    @displayView 'browse', @getView 'types', { types: @ibModel.types }
    
  showArtists: ->
    @ibModel.getHtml 'artists', {category: @category, section: @section}, (html) =>
      @displayView 'artistList', html
      
  showAlbums: ->
     @ibModel.getHtml 'albums', {artist: @artist, section: @section, category: @category}, (html) =>
        @displayView 'albumList', html
        @parent.registerDroppable $('#albumList .images td')
        @parent.registerDraggable $("#albumList .images .img"), false
    
  displayView: (viewId, html) ->
    switch viewId
    
      when 'browse'
        @category = null
        @showIcons '.browseHeader, .searchWrap'
        @updateView null, null, viewId, null, html
        
      when 'artistList'
        @artist = null
        @showIcons '.backArrow, h1, .searchWrap'
        @updateView 'browse', 'browse', viewId, @category, html
        
      when 'albumList'
        @showIcons '.backArrow, h1, .play, .manage, .searchWrap, .drag'
        @updateView 'artistList', @category, viewId, @artist, html
        
      when 'searchResults'
        @showIcons '.browseWrap, .searchFieldWrap, .drag'
        @updateView null, null, viewId, null, html
        
    @currentView = name 
    
  updateView: (previousId, previousName, currentId, currentName, html) ->
    # update head
    backArrow = $(".backArrow") 
    backArrow.attr 'name', previousId if previousId?
    $(".content span", backArrow).text previousName if previousName?
    $('.content .img', backArrow).toggle previousName is 'browse'
    $('#frame.browser h1').text currentName if currentName

    @hideAllViews()

    if $("##{currentId}").exists() and html?
      $("##{currentId}").replaceWith html
    else
      $('#browse').after html
    
    $("##{currentId}").show()


  ## DOM Events ##
  
  #- Top Header

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
    
        
  #- Browse
  
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
  
  #- Artists

  '#artistList tr.artist click': (el) ->
    return if not $('.artistName',el).attr 'readonly'
    @artist = $('.artistName',el).val()
    @showAlbums()
    
  #- Albums
  
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

  #- Edit (used by both Artist and Album List)
  
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
    
    image = {}
    image[field] = newValue
    if field is 'album'      
      $("#albumList tr.images[data-album='#{oldValue}'] .img").each (i, el) =>
        imageId = $(el).data 'id'
        @imageModel.update imageId, {image: image}
      $("#albumList tr[data-album='#{oldValue}']").each (i, el) =>
        $(el).data 'album', newValue
        log $(el).html()
        log $(el).data 'album'
      #$("#albumList tr[data-album='#{newValue}']").each (i, el) =>  
      #@refreshView() #todo
        
    else if field is 'artist'
      # todo
      alert 'cannot update this!'
      el.val oldValue
      
  #- Search Results -#
  
  '.searchField input[type="text"] keypress': (el, ev) ->
    $('.searchField .search').click() if ev.keyCode is 13

  '.searchField .search click': (el) ->
    @imageModel.search @parent.getSearchOptions(), (images) =>
      @displayView 'search_results', @getView('searchresults',{ images : images } )
      @parent.registerDraggable $("#searchResults ul li")
  
  '.searchField .options click': (el) ->    
    if not $('#searchOptions').is ':visible'
      @hideAllViews()
      el.addClass 'selected'
      @parent.showSearchOptions @getState()
    else
      el.removeClass 'selected'
      @displayView @currentView
      @showIcons '.browseWrap, .searchFieldWrap'
  
  '#searchResults li click': (el) ->
    @parent.showSlideshow 'searchResults', el.data 'id'
