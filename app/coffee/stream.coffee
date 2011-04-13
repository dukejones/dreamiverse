
$(document).ready ->
  streamController = new StreamController()


class StreamController
  constructor: ->
    @streamModel = new StreamModel()
    @streamView = new StreamView()

    $.subscribe 'filter:change', => 
      @streamModel.updateFilters().then (data) =>
        $.publish 'stream:update', [data.html]

    $.subscribe 'stream:update', (html) => @streamView.update(html)
    $.subscribe 'stream:append', (html) => @streamView.append(html)
  
  fetchPage: (page)->
    # html = 



class StreamView
  constructor: () ->
    @$container = $('#entryField .matrix')
    # Setup lightbox for stream
    $('a.lightbox').each((i, el) ->
      $(this).lightBox({containerResizeSpeed: 0});
    )
    # adds the loading wheel
    $('.filterList').click( (event) =>
      $(event.currentTarget).parent().find('.trigger').addClass('loading')
    )
  
  update: (html) ->
    if html == ''
      $('.noEntrys').show()
    else
      $('.noEntrys').hide()

    # after data loads into view, remove the loading spinner
    $('.entryFilter.trigger').removeClass('loading')
    $('.followFilter.trigger').removeClass('loading')

    @$container.html(html)
  append: (html) ->
    @$container.append(html)



class StreamModel
  load: (opts)->
    $.getJSON("/stream.json", opts).promise()  
  updateFilters: ->
    @filters = []
    # get new filter values (will be .filter .value to target the span)
    $.each $('.trigger .value'), (key, value) =>
      @filters.push($(value).text())  # XXX: data tightly coupled to display.
    
    @load({
      filters:
        type: @filters[0]
        friend: @filters[1]
        starlight: @filters[2]
    })


