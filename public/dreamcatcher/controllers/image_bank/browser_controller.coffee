$.Controller 'Dreamcatcher.Controllers.ImageBank.Browser',

  ibModel: Dreamcatcher.Models.ImageBank
  imageModel: Dreamcatcher.Models.Image
  
  views: ['browse', 'genreList', 'artistList', 'albumList', 'searchOptions', 'searchResults']
  
  getView: (url, data) ->
    return @view "//dreamcatcher/views/image_bank/browser/#{url}.ejs", data
  
  init: ->
    html = @getView 'types', { types: @ibModel.types }
    @displayView 'browse', html
  
  show: ->
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
    $("#categories").replaceWith @getView 'categories', { categories: @categories }
  
  
  '#categories .category click': (el) ->
    @category = el.text().trim()
    @artist = null
    @ibModel.getHtml 'artists', {category: @category, section: @section}, (html) =>
      @displayView 'artistList', html    
  
  
  #- ArtistList -#

  '#artistList tr.artist click': (el) ->
    return if not $('.artistName',el).attr 'readonly'
    
    @artist = $('.artistName',el).val()
    @ibModel.getHtml 'albums', {artist: @artist, section: @section, category: @category}, (html) =>
      @displayView 'albumList', html
      
    
  #- Album List -#
  
  '#albumList .manage click': (el) ->
    tr = el.closest 'tr'
    album = tr.data 'album'
    @parent.showManager $('.img', tr.next()), album
  
  '#albumList .images .img img click': (el) ->
    @parent.showSlideshow $('.img', el.closest 'tr'), el.parent().index()
    
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
    editable.focus()

  '.editable keypress': (el, event) ->
    el.blur() if event.keyCode is 13

  '.editable blur': (el) ->
    el.attr 'readonly', true
    el.removeClass 'hover'

    field = el.closest('table').attr 'id'
    field = field.replace('List','')
    newVal = el.val()
    
    if field is 'album'
      oldVal = el.closest('tr').data 'album'
      $("#albumList tr.images[data-album='#{oldVal}'] .img")
    
    log field+' '+val
    
    
  #- SearchResults -#
  
  '.searchField input[type="text"] keypress': (el, ev) ->
    $('.searchField .search').click() if ev.keyCode is 13

  '.searchField .search click': (el) ->
    @imageModel.search @parent.getSearchOptions(), (images) =>
      @displayView 'searchResults', @getView('searchresults',{ images : images } )
      @parent.registerDraggable $("#searchResults ul li")
      
  '.spinner click': (el) ->
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
