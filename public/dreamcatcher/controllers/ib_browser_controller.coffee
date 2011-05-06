$.Controller 'Dreamcatcher.Controllers.IbBrowser',

  model: Dreamcatcher.Models.ImageBank

  init: ->
    @section = "Library"
    $("#genreList").html @view('categories',{categories: @model.categories})
    
  '.subGenres span click': (el) ->
    @genre = el.text()

    $.get "/artists?genre=#{@genre}&section=#{@section}",(artists) ->
      $("#genreList").hide()
      $("#genreList").after(artists)
      $("#artistList").show()
  
  'tr.artist h2 click': (el) ->
    @artist = $(el).text()
    alert "/albums?artist=#{@artist}&section=#{@section}&genre=#{@genre}"
    #$.get "/albums?artist=#{@artist}&section=#{@section}&genre=#{@genre}",(albums) ->
    #  alert albums.html()
      
  '.backArrow click': (el) ->
    $("#genreList").show()
    $("#artistList").hide()
  
      
  

