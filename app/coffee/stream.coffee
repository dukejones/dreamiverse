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
    $.getJSON("/stream.json", {
      filters:
        type: @filters[0]
        friend: @filters[1]
        starlight: @filters[2]
    },
    (data) =>
      log data
    )
    # $.ajax {
    #       type: 'GET'
    #       dataType: 'json'
    #       url: '/stream'
    #       data:
    #         type_filter: @filters[0]
    #         friend_filter: @filters[1]
    #         starlight_filter: @filters[2]
    #       complete: (data, status, xhr) =>
    #         log data
    #         log status
    #       success: (data, status, xhr) =>
    #         log data
    #         $.publish('stream:update', [data])
    #     }
    
  updateFilters: () ->
    @filters = []
    # get new filter values (will be .filter .value to target the span)
    $.each $('.trigger .value'), (key, value) =>
      @filters.push($(value).text())
    @updateData()