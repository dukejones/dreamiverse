$.Controller 'Dreamcatcher.Controllers.Stream'

  init: ->
    Stream.page = 1
    @container = $('#entryField .matrix.stream')
    @activateLightBox()   
    @loadNextPage() # we want to load 2 pages on load (the first page was loaded with ruby)
    
    @bind window, 'scroll', 'scrollEvent'
    @bind $('#entry-filter, #users-filter'), 'change', 'dropdownChange'

  scrollEvent: ->
    if ($(window).scrollTop() > $(document).height() - $(window).height() - 200)
      @loadNextPage()
    
  loadNextPage: ->
    Stream.page += 1
    Stream.load(@getOptions(), @callback('updateStream'))

    @clear()
    $('#nextPageLoading').show()
    
  updateStream: (json) ->
    @clear()
    
    if !json.html? || json.html == ""
      Stream.noMore()
      $('#noMoreEntries').show() # No more entries to load.
    
    @container.empty() if Stream.page == 1
    @container.append json.html
    @activateLightBox()     
  
  getOptions: ->
    type: $('#entry-filter').val()
    users: $('#users-filter').val()
  
  # Setup lightbox for stream  
  activateLightBox: ->
    $('a.lightbox').each((i, el) ->
      $(this).lightBox({containerResizeSpeed: 0});
    )
    
  clear: ->
    $('#noMoreEntries, .noEntrys, #nextPageLoading, #entry-filter-wrap .spinner, #users-filter-wrap .spinner').hide()    
  
  # Form listeners    
  dropdownChange: (el)->
    Stream.reset()

    el.prev(".spinner").show()
    Stream.load @getOptions(), @callback('updateStream')
    
