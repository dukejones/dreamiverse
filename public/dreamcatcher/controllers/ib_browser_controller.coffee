$.Controller 'Dreamcatcher.Controllers.IbBrowser',

  model: Dreamcatcher.Models.ImageBank
  allViews: ['browse','genreList','artistList','albumList','searchOptions','searchResults','slideshow']
  
  hideAllViews: ->
    for view in @allViews
      @lastView = view if $("##{view}").is(":visible")
    return $( '#'+@allViews.join(', #') ).hide()
    
  showLastView: ->
    @displayScreen @lastView,null if @lastView?
    
  showIcons: (icons) ->
    $(".top,.footerButtons").children().hide()
    $(icons,".top,.footerButtons").show()    
      
  init: ->
    @imageCookie = new Dreamcatcher.Classes.CookieHelper "imagebank"
    @displayScreen "browse",@view('types', { types: @model.types })

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
        @updateScreen null,null,'#slideshow',null,null

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

  '.search click': ->
    if not $('.searchFieldWrap').is(':visible')
      @showIcons '.browseWrap, .searchFieldWrap'
    else
      data = @getSearchOptions()
      @model.searchImages data,@callback('displaySearchResults'
  
  '.play click': ->
    @displayScreen 'slideshow',null
    
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
      $("#albumList .images .img").draggable()
      $(".dropbox").show()
      $(".dropbox .imagelist").droppable({
        drop: (ev, ui) ->
          alert 'x'#TODO
      })
  
  #- albumList
  '#albumList .add click': (el) ->
    img = el.parent()
    img.addClass("selected")
    id = img.data('id')
    @imageCookie.add id
    
  #- searchOptions
  displaySearchResults: (images) ->
    @displayScreen 'searchResults',@view('searchresults',{ images : images } )
    
  '.searchField .options click': (el) ->
    if not $("#searchOptions").is(":visible")
      @hideAllViews()
      el.addClass("selected")
      for category in @categories
        $('#searchOptions .category select').append("<option>#{category}</option>")
      $("#searchOptions .genres").html @view('genres',{genres: @model.genres})
      $("#searchOptions").show()
      $(".category .list")
    else
      @showLastView()

  '#searchOptions .genre click': (el) ->
    if el.hasClass("selected") then el.removeClass("selected") else el.addClass("selected")
    
  getSearchOptions: ->
    options = {}
    options.q = $(".searchField input.input").val()
    for attr in ['artist','album','title','year','tags']
      val = ""
      inputElement = $("##{attr} input[type='text']");
      val = inputElement.val().trim() if inputElement.val()?
      options[attr] = val if val.length > 0
    log options
    
    #genres = []
    #$(".genre.selected").each (index,element) ->
    #  genres.push $(element).text()
    #options['genres'] = genres.join(',')
      
  

