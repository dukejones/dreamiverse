$.Controller 'Dreamcatcher.Controllers.Stream',

  init: ->
    Stream.page = 1
    @container = $('#entryField .matrix.stream')
    @activateLightBox()   
    @loadNextPage() # we want to load 2 pages on load (the first page was loaded with ruby)
    
    @bind window, 'scroll', 'scrollEvent'
    
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
      Stream.currentlyLoading = true
      $('#noMoreEntries').show() # No more entries to load.
      
    $("#entry-filter-wrap .spinner, #users-filter-wrap .spinner").hide()
    
    if Stream.page > 1
      @container.append json.html
    else
      @container.html json.html
      
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
    $('#noMoreEntries, .noEntrys, #nextPageLoading').hide()    
  
  # Form listeners    
  '#entry-filter, #users-filter change': (el) ->
    Stream.page = 1
    $("##{el.attr('id')}-wrap .spinner").show()
    Stream.load @getOptions(), @callback('updateStream')
    
