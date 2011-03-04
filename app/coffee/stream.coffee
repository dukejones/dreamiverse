
$(document).ready ->
  streamController = new StreamController()

class StreamController
  constructor: ->
    # listen for filter:change update
    $.subscribe 'filter:change', => @streamModel.updateFilters()
    
    $.subscribe 'stream:update', (html) => @streamView.update(html)
    
    @streamModel = new StreamModel()
    @streamView = new StreamView()
    
    # Setup youtube images for each entry
    
    # Setup lightbox for stream
    $('a.lightbox').lightBox({containerResizeSpeed: 100});
    



class StreamView
  constructor: () ->
    @$container = $('#entryField .matrix')
    
  update: (html) ->
    if html == ''
      $('.noEntrys').show()
    else
      $('.noEntrys').hide()
      
    @$container.html(html)



class StreamModel
  updateData: ->
    $.getJSON("/stream.json", {
      filters:
        type: @filters[0]
        friend: @filters[1]
        starlight: @filters[2]
    },
    (data) =>
      $.publish 'stream:update', [data.html]
    )
    
  updateFilters: () ->
    @filters = []
    # get new filter values (will be .filter .value to target the span)
    $.each $('.trigger .value'), (key, value) =>
      @filters.push($(value).text())  # data tightly coupled to display.
    @updateData()
    