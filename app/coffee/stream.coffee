
$(document).ready ->
  streamController = new StreamController()


class StreamController
  constructor: ->
    @stream = new StreamModel()
    @streamView = new StreamView(@stream)

    $.subscribe 'filter:change', => 
      @stream.load().then (data) =>
        @streamView.update(data.html)

  


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
  clear: ->
    $('#noMoreEntries').hide()
    $('.noEntrys').hide()
    
  loadNextPage: ->
    @clear()
    @page += 1
    @stream.load({ page: @page }).then (data)=>
      if !data.html? || data.html == ""
        $('#noMoreEntries').show()
        
      @$container.append(data.html)
  update: (html) ->
    @clear()
    if html == ''
      $('.noEntrys').show()

    # after data loads into view, remove the loading spinner
    $('.entryFilter.trigger').removeClass('loading')
    $('.followFilter.trigger').removeClass('loading')

    @$container.html(html)
    



class StreamModel
  load: (filters={})->
    @updateFilters()
    $.extend(filters, @filterOpts())
    $.getJSON("/stream.json", {filters: filters}).promise()  
  updateFilters: ->
    @filters = []
    # get new filter values (will be .filter .value to target the span)
    $.each $('.trigger span.value'), (key, value) =>
      @filters.push($(value).text())  # XXX: data tightly coupled to display.
  filterOpts: ->
    type: @filters[0]
    friend: @filters[1]
    # starlight: @filters[2]

