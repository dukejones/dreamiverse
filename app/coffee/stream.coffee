
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
    @activateLightBox()
    # adds the loading wheel
    $('.filterList').click( (event) =>
      $(event.currentTarget).parent().find('.trigger').addClass('loading')
    )
    # infinite scrolling
    $(window).scroll =>
      if ($(window).scrollTop() > $(document).height() - $(window).height() - 200)
        @loadNextPage()
  clear: ->
    $('#noMoreEntries, .noEntrys, #nextPageLoading').hide()
  activateLightBox: ->
    # Setup lightbox for stream
    $('a.lightbox').each((i, el) ->
      $(this).lightBox({containerResizeSpeed: 0});
    )
  loadNextPage: ->
    return if @currentlyLoading
    @currentlyLoading = true
    @clear()
    $('#nextPageLoading').show()
    @page += 1
    @stream.load({ page: @page }).then (data)=>
      @clear()
      @currentlyLoading = false
      if !data.html? || data.html == ""
        @currentlyLoading = true # No more entries to load.
        $('#noMoreEntries').show()
        
      @$container.append(data.html)
      @activateLightBox()
  update: (html) ->
    @clear()
    if html == ''
      $('.noEntrys').show()

    # after data loads into view, remove the loading spinner
    $('.entryFilter.trigger').removeClass('loading')
    $('.followFilter.trigger').removeClass('loading')

    @$container.html(html)
    @activateLightBox()
    



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

