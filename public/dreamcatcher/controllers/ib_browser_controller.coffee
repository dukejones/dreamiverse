$.Controller 'Dreamcatcher.Controllers.IbBrowser',

  model: Dreamcatcher.Models.ImageBank
  
  init: ->
    @imageCookie = new Dreamcatcher.Classes.CookieHelper "imagebank"
    $("#searchOptions").hide()#TODO
    #@imageCookie.clear()
    @section = "Library"#TODO
    $("#frame .top").after @view('types',{types: @model.types})
    #@displayScreen "#genreList", @view('types',{types: @model.types})
    #@displayScreen "#genreList", @view('categories',{categories: @model.categories})
    #$("#searchOptions .genres").html @view('genres',{categories: @model.categories})

  updateScreen: (previousType, previousName, currentType, currentName, currentHtml) ->
    $("#genreList,#artistList,#albumList").hide()
    $(".backArrow .content").text(previousName)
    $(".backArrow").attr("name",previousType)
    if previousType? then $(".backArrow").show() else $(".backArrow").hide()
    $("h1").text(currentName)
    $(currentType).replaceWith(currentHtml) if currentHtml?
    $(currentType).show()
    
    if currentType is "#albumList" and currentHtml?
      $("#albumList .img").each (index,element) =>
        id = $(element).data 'id'
        if @imageCookie.contains id
          $(element).addClass('selected')
    
  displayScreen: (type, html) ->
    switch type
      when "#genreList"
        @updateScreen null,null,"#genreList","Genres",html
      when "#artistList"
        @updateScreen "#genreList","Genres","#artistList",@genre,html
      when "#albumList"
        @updateScreen "#artistList",@genre,"#albumList",@artist,html 

  '.backArrow click': (el) ->
    @displayScreen el.attr("name"),null
    
  '.type click': (el) ->
    categories = el.data('categories').split(',')
    @displayScreen "#genreList", @view('categories',{categories: categories})
    
    
  '.subGenres span click': (el) ->
    @genre = el.text()
    $.get "/artists?genre=#{@genre}&section=#{@section}",(html) =>
      @displayScreen "#artistList",html
  
  'tr.artist click': (el) ->
    @artist = $("h2:first",el).text()
    $.get "/albums?artist=#{@artist}&section=#{@section}&genre=#{@genre}",(html) =>
      @displayScreen "#albumList",html
      
  '#albumList .add click': (el) ->
    img = el.parent()
    img.addClass("selected")
    id = img.data('id')
    @imageCookie.add id
    
  '.search click': (el) ->
    $("#genreList,#artistList,#albumList").hide() #repeated code
    $("#searchOptions").show()
    
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
      
  

