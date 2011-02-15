streamController = null

$(document).ready ->
  streamController = new StreamController()

class StreamController
  constructor: ->
    # listen for filter:change update
    $.subscribe 'filter:change', => @streamModel.updateFilters()
    
    $.subscribe 'stream:update', (elements) => @streamView.update(elements)
    
    @streamModel = new StreamModel()
    @streamView = new StreamView()



class StreamView
  constructor: () ->
    @$container = $('#entryField .matrix')
    
  update: (elements) ->
    @$container.html(elements)



class StreamModel
  updateData: ->
    # Update data from server
    $.get('/stream', {filters: @filters}, (data) =>
      # Send results to the controller
      $.publish('stream:update', [data])
    )
    
  updateFilters: () ->
    @filters = []
    # get new filter values (will be .filter .value to target the span)
    $.each $('.followFilter span'), (key, value) =>
      alert key + $(value).text()
      @filters.push($(value).text())