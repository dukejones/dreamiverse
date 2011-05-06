$.Controller 'Dreamcatcher.Controllers.IbBrowser',

  model: Dreamcatcher.Models.ImageBank

  init: ->
    @section = "Library"
    $("#genreList").html @view('categories',{categories: @model.categories})
    
  '.subGenres span click': (el) ->
    @genre = el.text()

    $(".backArrow span").text("Home")    
    $("h1").text(@genre)

    $.get "/artists?genre=#{@genre}&section=#{@section}",(artists) ->
      $("#genreList").hide()
      $("#genreList").after(artists)
      $("#artistList").show()
  
  'tr.artist click': (el) ->
    @artist = $("h2:first",el).text()
    
    $(".backArrow span").text(@genre)
    $("h1").text(@artist)
    
    $.get "/albums?artist=#{@artist}&section=#{@section}&genre=#{@genre}",(albums) ->
      $("#artistList").hide()
      $("#artistList").after(albums)
      $("#albumList").show()
      
  '.backArrow click': (el) ->
    $("#genreList").show()
    $("#artistList").hide()
  
      
  

