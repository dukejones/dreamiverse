$.Controller 'Dreamcatcher.Controllers.Bedsheet',

  #TODO: incorporate select album/genre functionality
  #TODO: look at doing a loading spinner if bedsheets haven't been loaded yet
  
  init: ->
    Dreamcatcher.Models.Bedsheet.findAll({}, @callback('populate'))

  setParent: (parent) ->
    @parent = parent
    
  populate: (bedsheets) ->
    $("#bedsheetScroller ul").html(@view('list',{bedsheets: bedsheets}))

  '.bedsheet click': (el) ->
    bedsheet = el.closest('.bedsheet').model()
    bedsheetUrl = "url('/images/uploads/#{bedsheet.id}-bedsheet.jpg')"
    $('#body').css('background-image', bedsheetUrl)
    @parent.update(
      bedsheet_id: bedsheet.id
    )

