$.Controller 'Dreamcatcher.Controllers.IbBrowser',

  model: Dreamcatcher.Models.ImageBank
  allViews: ['browse','genreList','artistList','albumList','searchOptions','searchResults','slideshow','dropbox']
  
  init: ->
    @imageCookie = new Dreamcatcher.Classes.CookieHelper "imagebank"
    @displayScreen "browse",@view('types', { types: @model.types })
  
  hideAllViews: ->
    for view in @allViews
      @lastView = view if $("##{view}").is(":visible")
    return $( '#'+@allViews.join(', #') ).hide()
    
  showLastView: ->
    @displayScreen @lastView,null if @lastView?
    
  showIcons: (icons) ->
    $(".top,.footerButtons").children().hide()
    $(icons,".top,.footerButtons").show()    
      


  displayScreen: (type, html) ->
    switch type
      when "browse"
        @showIcons ".browseHeader, .searchWrap"
        @updateScreen null,null,"#browse",null,html
      when "artistList"
        @showIcons ".browseWrap, h1, .searchWrap"
        @updateScreen "#browse",null,"#artistList",@category,html
      when "albumList"
        @showIcons ".browseWrap, .backArrow, h1, .play, .manage, .searchWrap, .drag"
        @updateScreen "#artistList",@category,"#albumList",@artist,html
      when 'searchResults'
        @updateScreen null,null,'#searchResults',null,html
      when 'slideshow'
        @showIcons '.counter,.play'
        @updateScreen null,null,'#slideshow',null,html

  updateScreen: (previousType, previousName, currentType, currentName, currentHtml) ->
    @hideAllViews()
    
    $(".backArrow .content").text(previousName) if previousName
    $(".backArrow").attr("name",previousType) if previousType
    $("h1").text(currentName) if currentName
    
    $(currentType).replaceWith(currentHtml) if currentHtml?
    $(currentType).show()
    
    ###
    if currentType is "#albumList" and currentHtml?
      $("#albumList .img").each (index,element) =>
        id = $(element).data 'id'
        if @imageCookie.contains id
          $(element).addClass('selected')
    ###
          
  ## TOP ICONS
    
  '.browseWrap click': (el) ->
    @displayScreen "browse",null

  '.backArrow click': (el) ->
    @displayScreen el.attr("name"),null

  '.searchWrap click': ->
    if not $('.searchFieldWrap').is(':visible')
      @showIcons '.browseWrap, .searchFieldWrap'
  
  '.play click': ->
    imageIds = @imageCookie.getAll()

    @displayScreen 'slideshow', @view('slideshow', { imageIds: imageIds })
    
  #VIEWS
    
  #- browse
  '#type li click': (el) ->
    $("#type li").removeClass('selected')
    el.addClass('selected')
    @section = @type = el.text().trim()
    @categories = el.data('categories').split(',')
    $("#categories").replaceWith @view('categories',{ categories: @categories })
  
  '#categories .category click': (el) ->
    @category = el.text().trim()
    $.get "/artists?category=#{@category}&section=#{@section}",(html) =>
      @displayScreen "artistList",html
  
  #- artistList
  '#artistList tr.artist click': (el) ->
    @artist = $("h2:first",el).text()
    $.get "/albums?artist=#{@artist}&section=#{@section}&category=#{@category}",(html) =>
      @displayScreen "albumList",html
      $("#albumList .images .img").draggable {
        containment: 'document'
        #helper: 'clone'
        #appendTo: '#dropbox'
        zIndex: 100
        #distance: 40
        #scroll: false
        #revert: false
        start: ->
          $("#dropbox").show()
          $(".drag").hide()
        #stop: ->
        #$("#dropbox").slideDown()
      }
      
      $("#dropbox").droppable {
        drop: (ev, ui) =>
          ui.draggable.css({top: '', left: ''}).appendTo("#dropbox .imagelist")
          @imageCookie.add ui.draggable.data('id')
      }
  
  #- albumList
  #'#albumList .add click': (el) ->
  #  img = el.parent()
  #  img.addClass("selected")
  #  id = img.data('id')
  #  @imageCookie.add id
    
  #- searchOptions    
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
  

