$.Controller 'Dreamcatcher.Controllers.Stream',

  # model: Dreamcatcher.Models.Stream

  init: ->
    @page =  1
    @container = $('#entryField .matrix')
    @initSelectMenu()
    @activateLightBox()
    
    # @loadNextPage() # we want to load 2 pages on load (first page was loaded with ruby)
    
    # infinite scrolling
    $(window).scroll =>
      if ($(window).scrollTop() > $(document).height() - $(window).height() - 200)
        log 'window scroll'
        @loadNextPage()
 
      
  '#entry-filter, #users-filter change': (el) ->
    @page = 1
    $("##{el.attr('id')}-wrap .spinner").show()
    Dreamcatcher.Models.Stream.load @getOptions(), @callback('updateStream')  

  initSelectMenu: ->
   $('.select-menu').selectmenu {
     style: 'dropdown'
     menuWidth: "200px"
     positionOptions:
       offset: "0px -37px"
   }

  clear: ->
    $('#noMoreEntries, .noEntrys, #nextPageLoading').hide()  
    
  loadNextPage: ->
    log 'running loadNextPage'
    return if @currentlyLoading
    @currentlyLoading = true
    @clear()
    $('#nextPageLoading').show()
    @page += 1
    log('page:' + @page)
    
    Dreamcatcher.Models.Stream.load @getOptions(), @callback('updateStream')
    
  updateStream: (json) ->
    log 'running updateStream'
    @clear()
    @currentlyLoading = false   
    
    if !json.html? || json.html == ""
      @currentlyLoading = true
      $('#noMoreEntries').show() # No more entries to load.
      
    $("#entry-filter-wrap .spinner, #users-filter-wrap .spinner").hide()
    
    if @page > 1
      @container.append json.html
    else
      @container.html json.html
      
    @activateLightBox()     
           
  getOptions: ->
    log 'running getOptions'
    filters: {
      page: @page
      type: $('#entry-filter').val()
      users: $('#users-filter').val()
    }
    
  activateLightBox: ->
    # Setup lightbox for stream
    $('a.lightbox').each((i, el) ->
      $(this).lightBox({containerResizeSpeed: 0});
    )    