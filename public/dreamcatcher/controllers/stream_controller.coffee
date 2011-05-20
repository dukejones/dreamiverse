$.Controller 'Dreamcatcher.Controllers.Stream',

  model: Dreamcatcher.Models.Stream

  init: ->
    @page = 1
    @container = $('#entryField .matrix')
    @initSelectMenu()
    # @loadNextPage()
    
    # infinite scrolling
    $(window).scroll =>
      if ($(window).scrollTop() > $(document).height() - $(window).height() - 200)
        @loadNextPage()
        
  clear: ->
    $('#noMoreEntries, .noEntrys, #nextPageLoading').hide()  
    
  loadNextPage: ->
    return if @currentlyLoading
    @currentlyLoading = true
    @clear()
    $('#nextPageLoading').show()
    @page += 1
    log('page:' + @page)
    
    Dreamcatcher.Models.Stream.load @getOptions(), @callback('updateStream')

    
    ###
    @stream.load({ page: @page }).then (data)=>
      @clear()
      @currentlyLoading = false
      if !data.html? || data.html == ""
        @currentlyLoading = true # No more entries to load.
        $('#noMoreEntries').show()
        
      @$container.append(data.html)
      @activateLightBox()
    ###
    
  initSelectMenu: ->
    $('.select-menu').selectmenu {
      style: 'dropdown'
      menuWidth: "200px"
      positionOptions:
        offset: "0px -37px"
    }
    
  getOptions: ->
    filters: {
      type: $('#entry-filter').val()
      users: $('#users-filter').val()
    }
    page: @page

  '#entry-filter, #users-filter change': (el) ->
    @page = 1
    $("##{el.attr('id')}-wrap .spinner").show()
    Dreamcatcher.Models.Stream.load @getOptions(), @callback('updateStream')
    
  updateStream: (json) ->
    @clear()
    @currentlyLoading = false
    if !json.html? || json.html == ""
      @currentlyLoading = true # No more entries to load.
      $('#noMoreEntries').show()    
    
    if @page > 1
      @container.append json.html
    else
      @container.html json.html
      $("#entry-filter-wrap .spinner, #users-filter-wrap .spinner").hide()
    

    