$.Controller('Dreamcatcher.Controllers.Bedsheets',

  init: ->
    Dreamcatcher.Models.Bedsheets.findAll({}, @callback('populate'))
    
  populate: (bedsheets) ->
    $("#bedsheetScroller ul").html(@view('list',{bedsheets: bedsheets}))

  '.bedsheet click': (el) ->
    bedsheet = el.closest('.bedsheet').model()
    bedsheetUrl = "url('/images/uploads/#{bedsheet.id}-bedsheet.jpg')"
    $('#body').css('background-image', bedsheetUrl)
    #@parent.update({ bedsheet_id: bedsheet.id, scrolling: null, theme: null})

)
