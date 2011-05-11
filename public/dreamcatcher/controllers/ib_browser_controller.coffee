$.Controller 'Dreamcatcher.Controllers.IbBrowser',

  model: Dreamcatcher.Models.ImageBank
  
  init: ->
    @imageCookie = new Dreamcatcher.Classes.CookieHelper "imagebank"
    $("#searchOptions").hide()
    
    @showIcons ".browseHeader, .searchWrap"
    # @updateScreen null,null,"#browse","browse",html
    
    $("#type").replaceWith @view('types',{types: @model.types})
    $("#type li:first").click()
    
  '#type li click': (el) ->
    $("#type li").removeClass('selected')
    el.addClass('selected')
    @section = @type = el.text().trim()
    $("#categories").replaceWith @view('categories',{ categories: el.data('categories').split(',') })
    
  '#categories .category click': (el) ->
    @category = el.text().trim()
    $.get "/artists?category=#{@category}&section=#{@section}",(html) =>
      @displayScreen "#artistList",html
      
  showIcons: (icons) ->
    $(".top,.footerButtons").children().hide()
    $(icons,".top,.footerButtons").show()

  displayScreen: (type, html) ->
    switch type
      when "#artistList"
        @showIcons ".browseWrap, h1, .searchWrap"
        @updateScreen "#type,#categories","Genres","#artistList",@genre,html
      when "#albumList"
        @showIcons ".browseWrap, .backArrow, h1, .play, .manage, .searchWrap, .drag"
        @updateScreen "#artistList",@genre,"#albumList",@artist,html

  updateScreen: (previousType, previousName, currentType, currentName, currentHtml) ->
    $("#browse,#artistList,#albumList").hide()
    $(".backArrow .content").text(previousName)
    $(".backArrow").attr("name",previousType)
    #if previousType? then $(".backArrow").show() else $(".backArrow").hide()
    $("h1").text(currentName)
    $(currentType).replaceWith(currentHtml) if currentHtml?
    $(currentType).show()
    
    if currentType is "#albumList" and currentHtml?
      $("#albumList .img").each (index,element) =>
        id = $(element).data 'id'
        if @imageCookie.contains id
          $(element).addClass('selected')
    


  '.backArrow click': (el) ->
    @displayScreen el.attr("name"),null
    
  '.type click': (el) ->
    categories = el.data('categories').split(',')
    @displayScreen "#genreList", @view('categories',{categories: categories})
  
  'tr.artist click': (el) ->
    @artist = $("h2:first",el).text()
    $.get "/albums?artist=#{@artist}&section=#{@section}&category=#{@category}",(html) =>
      @displayScreen "#albumList",html
      $("#albumList .images .img").draggable()
      $(".dropbox").show()
      $(".dropbox").droppable({
        drop: (ev, ui) ->
          alert 'x'#TODO
      })
      
  '#albumList .add click': (el) ->
    img = el.parent()
    img.addClass("selected")
    id = img.data('id')
    @imageCookie.add id
    
  '.search click': ->
    if $('.searchFieldWrap').is(':visible')
      $('.searchFieldWrap').hide()
      $(".browseHeader,.browseWrap,.backArrow,h1,.searchWrap,.timer,.manage,.play,.counter").show()
    else
      $('.searchFieldWrap').show()
      $(".browseHeader,.browseWrap,.backArrow,h1,.searchWrap,.timer,.manage,.play,.counter").hide()
      
  '.searchField .options click': ->
    $("#searchOptions").show()
    $("#genreList,#artistList,#albumList").hide() #repeated code
    #$("#searchOptions").show()
    
  #'.genre click': (el) ->
  #  if el.hasClass("selected") then el.removeClass("selected") else el.addClass("selected")
    
  getSearchOptions: ->
    options = {}
    for attr in ['artist','album','title','year','tag']
      val = $("##{attr} input[type='text]").val().trim()
      options[attr] = val if val.length > 0
    genres = []
    $(".genre.selected").each (index,element) ->
      genres.push $(element).text()
    options['genres'] = genres.join(',')
    log options
      
  

