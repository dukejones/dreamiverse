
$(document).ready ->
  streamController = new StreamController()
  streamController.streamView.loadNextPage()


class StreamController
  constructor: ->
    @stream = new StreamModel
    @streamView = new StreamView(@stream)

    $('#entry-filter, #users-filter').change( (event) =>
      @stream.load().then (data) =>
        @streamView.update(data.html)
    )
    


class StreamView
  constructor: (streamModel)->
    @page = 1
    @stream = streamModel
    @$container = $('#entryField .matrix')
    @activateLightBox()
    # adds the loading wheel

    $('#entry-filter, #users-filter').change( (event) =>
      $('#entry-filter-wrap .spinner').show() if event.currentTarget.id is 'entry-filter'
      $('#users-filter-wrap .spinner').show() if event.currentTarget.id is 'users-filter'
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
  loadNextPage: () ->
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
    log 'running StreamView update:'
    @clear()
    if html == ''
      $('.noEntrys').show()

    # after data loads into view, remove the loading spinner
    # $('#streamContextPanel .trigger').removeClass('loading')
    # and hide the filter spinners
    $('#entry-filter-wrap .spinner, #users-filter-wrap .spinner').hide()

    @$container.html(html)
    @activateLightBox()
    


class StreamModel
  load: (filters={}) ->
    @updateFilters()
    $.extend(filters, @filterOptions())
    $.getJSON("/stream.json", {filters: filters}).promise()  
  updateFilters: ->
    @entryFilter = $('#entry-filter').val()
    @usersFilter = $('#users-filter').val()    
    
    log '@entryFilter: ' + @entryFilter
    log '@usersFilter: ' + @usersFilter   

  filterOptions: ->
    type: @entryFilter
    users: @usersFilter
    # starlight: @filters[2]