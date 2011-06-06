$.Controller 'Dreamcatcher.Controllers.Users.Bedsheets',

  getView: (name, args) ->
    return @view "//dreamcatcher/views/bedsheets/#{name}.ejs", args
  
  load: (category) ->
    $("#bedsheetScroller .spinner").show()
    Dreamcatcher.Models.Bedsheet.findAll { category: category }, @callback('populate')
  
  populate: (bedsheets) ->
    $("#bedsheetScroller ul").html @getView 'list', { bedsheets: bedsheets }
    $("#bedsheetScroller ul").show()
    $("#bedsheetScroller .spinner").hide()
    
  highlight: (el) ->
    $(".bedsheet").removeClass 'selected'
    el.addClass 'selected'

  '.bedsheet click': (el) ->
    bedsheetId = el.data 'id'
    bedsheetUrl = "/images/uploads/#{bedsheetId}-bedsheet.jpg"
    
    img = $("<img src='#{bedsheetUrl}' style='display:none' />")
    $(img).load ->
      $('#body').prepend '<div id="backgroundReplace" style="width:100%; height: 100%; position: absolute; display: none; background-image: url('+bedsheetUrl+')"></div>'
      $('#backgroundReplace').fadeIn 2000, =>
        $('#backgroundReplace').remove()
        $('#body').css 'background-image', "url('#{bedsheetUrl}')"
    $('body').append img
    
    @highlight el 
    @publish 'appearance.update', { bedsheet_id: bedsheetId }