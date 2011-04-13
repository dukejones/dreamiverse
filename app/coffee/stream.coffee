
$(document).ready ->
  streamController = new StreamController()


class StreamController
  constructor: ->
    @stream = new StreamModel()
    @streamView = new StreamView(@stream)

    $.subscribe 'filter:change', => 
      @stream.updateFilters()
      @stream.load().then (data) =>
        $.publish 'stream:update', [data.html]

    $.subscribe 'stream:update', (html) => @streamView.update(html)
  


class StreamView
  constructor: (streamModel)->
    @page = 1
    @stream = streamModel
    @$container = $('#entryField .matrix')
    # Setup lightbox for stream
    $('a.lightbox').each((i, el) ->
      $(this).lightBox({containerResizeSpeed: 0});
    )
    # adds the loading wheel
    $('.filterList').click( (event) =>
      $(event.currentTarget).parent().find('.trigger').addClass('loading')
    )
    # infinite scrolling
    $(window).scroll =>
      if ($(window).scrollTop() == $(document).height() - $(window).height())
        @loadNextPage()
  
  loadNextPage: ->
    @page += 1
    @stream.updateFilters()
    @stream.load({ page: @page }).then (data)=>
      @$container.append(data.html)
  update: (html) ->
    if html == ''
      $('.noEntrys').show()
    else
      $('.noEntrys').hide()

    # after data loads into view, remove the loading spinner
    $('.entryFilter.trigger').removeClass('loading')
    $('.followFilter.trigger').removeClass('loading')

    @$container.html(html)
    



class StreamModel
  load: (filters={})->
    $.extend(filters, @filterOpts())
    $.getJSON("/stream.json", {filters: filters}).promise()  
  updateFilters: ->
    @filters = []
    # get new filter values (will be .filter .value to target the span)
    $.each $('.trigger .value'), (key, value) =>
      @filters.push($(value).text())  # XXX: data tightly coupled to display.
  filterOpts: ->
    type: @filters[0]
    friend: @filters[1]
    starlight: @filters[2]

