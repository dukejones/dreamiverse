$.Controller 'Dreamcatcher.Controllers.IbBrowser',

  model: Dreamcatcher.Models.ImageBank

  init: ->
    @section = "Library"
    $("#genreList").html @view('categories',{categories: @model.categories})
    
  updateTitle: (back,backType,current) ->
    $(".backArrow span").text(back)
    $(".backArrow").attr("name",backType)
    $("h1").text(current)
  
  displayScreen: (previous,current,html) ->
    $(previous).hide()
    $(previous).after(html) if not $(current).exists()
    $(current).show()
    
  '.subGenres span click': (el) ->
    @genre = el.text()
    @updateTitle "home","genre",@genre
    $.get "/artists?genre=#{@genre}&section=#{@section}",(artists) =>
      @displayScreen("#genreList","#artistList",artists)
  
  'tr.artist click': (el) ->
    @artist = $("h2:first",el).text()
    @updateTitle @genre,"artist",@artist
    $.get "/albums?artist=#{@artist}&section=#{@section}&genre=#{@genre}",(albums) =>
      @displayScreen("#artistList","#albumList",albums)
  
  '.backArrow click': (el) ->
    $("#genreList,#artistList,#albumList").hide()
    switch el.attr("name")
      when "genres" then $("#genreList").show()
      when "artists" then $("#artistList").show()
      when "albums" then $("#albumList").show()
