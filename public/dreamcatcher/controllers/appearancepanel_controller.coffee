$.Controller.extend('Dreamcatcher.Controllers.AppearancePanel',{
  onDocument: true
},{
  load: ->
    Dreamcatcher.Models.AppearancePanel.findAllBedsheets({}, @callback('list'))
    
  list: (bedsheets) ->
    $("#bedsheetScroller ul").html(@view('show',{bedsheets: bedsheets}))

  '.bedsheet click': (el, ev) ->
    alert 'x'
})