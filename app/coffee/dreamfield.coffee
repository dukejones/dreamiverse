
class window.DreamfieldController
  constructor: (username)->
    @dreamfield = new DreamfieldModel(username)
    @dreamfieldView = new DreamfieldView(@dreamfield)
        
class DreamfieldView
  constructor: (dreamfieldModel)->
    @page = 1
    @entryCount = $('.entryCount').data('id')
    @pageSize = $('.pageSize').data('id')
    @totalPages = Math.ceil @entryCount / @pageSize
    @dreamfield = dreamfieldModel
    @$container = $('#pagination')

    $('#pagination').live "mouseenter", (event) =>
      $('#pagination .next .text').show()
      $('#pagination .all').show()
      
    .live "mouseleave", (event) =>
      $('#pagination .next .text').fadeOut('fast')
      $('#pagination .all').fadeOut('fast')

    
    $('.next').click( (event) =>
      @loadNextPage()
      return false
    )
    
    $('.all').click( (event) =>
      @loadNextPage(true)
      return false
    )
        
  clear: ->
    $('#pagination .next').removeClass('loading')

  loadNextPage: (showAll=false)->
    return if @currentlyLoading
    $('#pagination .next').addClass('loading')
    @page += 1
    
    @dreamfield.load({ page: @page, show_all: showAll }).then (data)=>
      @clear()
      if !data.html? || data.html == ""
        $('.next').parent().hide()
      
      if showAll || @page >= @totalPages
        $('.next').parent().hide()

      @$container.before(data.html)

      
  update: (html) ->
    @clear()
    if html == ''
      $('.noEntrys').show()

    @$container.html(html)



class DreamfieldModel
  constructor: (username)->
    @username = username
  load: (filters={})->
    $.extend(filters, { type: @typeFilter() })
    $.getJSON("/"+@username+".json", {filters: filters}).promise()
  typeFilter: ->
    # XXX: View is tightly coupled to the data being passed.
    # Extra code is required on the server to deal with strings like "all entries" being passed 
    # when what we really mean is no type filter.
    # _stream_context_panel.haml has data-filter attributes.  We should be using those instead of
    # introspecting into the view and passing that as data.
    type = $('.entryFilter.entries .value').text()
    if type == 'entries' then "" else type


