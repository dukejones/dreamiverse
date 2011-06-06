$.Controller 'Dreamcatcher.Controllers.Users.Bedsheets',
  
  load: (category) ->
    $("#bedsheetScroller .spinner").show()
    Dreamcatcher.Models.Bedsheet.findAll { category: category }, @callback('populate')
  
  populate: (bedsheets) ->
    $("#bedsheetScroller ul").html @view 'list', { bedsheets: bedsheets }
    $("#bedsheetScroller ul").show()
    $("#bedsheetScroller .spinner").hide()
    
  highlight: (el) ->
    $(".bedsheet").removeClass 'selected'
    el.addClass 'selected'

  '.bedsheet click': (el) ->
    bedsheetId = el.data 'id'
    $('#body').css 'background-image', "url('/images/uploads/#{bedsheetId}-bedsheet.jpg')"
    @highlight el 
    @publish 'appearance.update', { bedsheet_id: bedsheetId }