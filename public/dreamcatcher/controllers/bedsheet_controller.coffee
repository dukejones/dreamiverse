$.Controller 'Dreamcatcher.Controllers.Bedsheet',

  #TODO: incorporate select album/genre functionality
  #TODO: look at doing a loading spinner if bedsheets haven't been loaded yet
  #TODO: ajax upload calls aren't working for some reason...
  
  init: ->
    #replace with 'empty' - in DOM say "please select genre first"
    #otherwise if dom is selected
    #Dreamcatcher.Models.Bedsheet.findAll({}, @callback('populate'))

  setParent: (parent) ->
    @parent = parent
    
  updateGenre: (genre) ->
    Dreamcatcher.Models.Bedsheet.findAll({genre: genre}, @callback('populate'))
    
  #TODO: perhaps show selected the one that is being used? - modify bedsheet/show.ejs
  #TODO: hide ajax spinner here.
  
  populate: (bedsheets) ->
    $("#bedsheetScroller ul").html(@view('list',{bedsheets: bedsheets}))
    
  highlightBedsheet: (el) ->
    $(".bedsheet").removeClass("selected")
    el.addClass("selected") #TODO: add CSS style


  '.bedsheet click': (el) ->
    @bedsheet = el.closest('.bedsheet').model()
    
    $('#body').css('background-image', "url('/images/uploads/#{bedsheet.id}-bedsheet.jpg')")
    @highlightBedsheet el  
    
    @parent.update(
      bedsheet_id: bedsheet.id
    )
    

    

