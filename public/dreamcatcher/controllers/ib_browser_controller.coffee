$.Controller 'Dreamcatcher.Controllers.IbBrowser',

  model: Dreamcatcher.Models.ImageBank
  
  init: ->
    @imageCookie = new Dreamcatcher.Classes.CookieHelper "imagebank"
    #@imageCookie.clear()
    @section = "Library"
    html = @view('categories',{categories: @model.categories})
    @displayScreen "#genreList",html

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
  

