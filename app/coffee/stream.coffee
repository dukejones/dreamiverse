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
    #alert @filters[2]
    #window.location = '/stream?starlight_filter=' + @filters[2] + '&friend_filter=' + @filters[1]
    # Update data from server
    $.ajax {
      type: 'GET'
      url: '/stream'
      data:
        type_filter: @filters[0]
        friend_filter: @filters[1]
        starlight_filter: @filters[2]
      success: (data, status, xhr) =>
        $.publish('stream:update', [data])
    }
    
  updateFilters: () ->
    @filters = []
    # get new filter values (will be .filter .value to target the span)
    $.each $('.trigger .value'), (key, value) =>
      @filters.push($(value).text())
    @updateData()