$.Controller 'Dreamcatcher.Controllers.Bedsheet',
    
  updateGenre: (genre) ->
    Dreamcatcher.Models.Bedsheet.findAll({genre: genre}, @callback('populate'))
  
  populate: (bedsheets) ->
    $("#bedsheetScroller ul").html(@view('list',{bedsheets: bedsheets}))
    
  highlightBedsheet: (el) ->
    $(".bedsheet").removeClass("selected")
    el.addClass("selected")


  '.bedsheet click': (el) ->
    bedsheet = el.closest('.bedsheet').model()
    $('#body').css('background-image', "url('/images/uploads/#{bedsheet.id}-bedsheet.jpg')")
    @highlightBedsheet el  
    
    @options.parent.updateAppearanceModel(
      bedsheet_id: bedsheet.id
    )

