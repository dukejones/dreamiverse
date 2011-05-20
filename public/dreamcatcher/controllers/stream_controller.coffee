$.Controller 'Dreamcatcher.Controllers.Stream',

  init: ->
    @page = 1
    @container = $('#entryField .matrix')
    @initSelectMenu()
    @activateLightBox()   
    @loadNextPage() # we want to load 2 pages on load (the first page was loaded with ruby)
    
    # infinite scrolling
    $(window).scroll =>
      if ($(window).scrollTop() > $(document).height() - $(window).height() - 200)
        # log 'window scroll'
        @loadNextPage()
 
      
  '#entry-filter, #users-filter change': (el) ->
    @page = 1
    $("##{el.attr('id')}-wrap .spinner").show()
    Dreamcatcher.Models.Stream.load @getOptions(), @callback('updateStream')  

  clear: ->
    $('#noMoreEntries, .noEntrys, #nextPageLoading').hide()  
    
  loadNextPage: ->
    return if @currentlyLoading
    # log 'running loadNextPage'
    @currentlyLoading = true
    @page += 1
    @clear()
    
    $('#nextPageLoading').show()
    
    Dreamcatcher.Models.Stream.load @getOptions(), @callback('updateStream')
    
  updateStream: (json) ->
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
  
  # Generate model options   
  getOptions: ->
    filters: {
      page: @page
      type: $('#entry-filter').val()
      users: $('#users-filter').val()
    }

  initSelectMenu: ->
   $('.select-menu').selectmenu {
     style: 'dropdown'
     menuWidth: "200px"
     positionOptions:
       offset: "0px -37px"
   }
  
  # Setup lightbox for stream  
  activateLightBox: ->
    $('a.lightbox').each((i, el) ->
      $(this).lightBox({containerResizeSpeed: 0});
    )    