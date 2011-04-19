$(document).ready ->
  dreamfieldController = new DreamfieldController()


class DreamfieldController
  constructor: ->
    @dreamfield = new DreamfieldModel()
    @dreamfieldView = new DreamfieldView(@dreamfield)
        
class DreamfieldView
  constructor: (dreamfieldModel)->
    @page = 1
    @dreamfield = dreamfieldModel
    @$container = $('#paginationAnchor').find('.thumb-2d').last()
    
    $('.next').click( (event) =>
      log('next')
      @loadNextPage()
      return false
    )
    
    $('.all').click( (event) =>
      log('all')
      @loadNextPage(true)
      return false
    )
        
  clear: ->
    $('#pagination .next').removeClass('loading')

  loadNextPage: (showAll)->
    return if @currentlyLoading
    @currentlyLoading = true
    @clear()
    $('#pagination .next').addClass('loading')
    @page += 1
    
    if showAll
      @page = 'all'
      
      # $('#nextPageLoading').show()
      # $('<div class="thumb-2d"></div>').insertAfter('.matrix')
      # $('.matrix').hide()
      # $('<div class="matrix"></div>').append('#entryField')
      @$container = $('.matrix')
    
    log('page: ' + @page)
    @dreamfield.load({ page: @page }).then (data)=>
      @clear()
      @currentlyLoading = false
      if !data.html? || data.html == ""
        @currentlyLoading = true # No more entries to load.
        $('.next').parent().hide()
      
      $('#nextPageLoading').hide()

      if showAll
        $('.matrix').find('.thumb-2d').hide() # clear existing thumbs to make room for all
        $('.next').parent().hide()
        @$container.append(data.html) 
      else
        @$container.after(data.html)
      
  update: (html) ->
    @clear()
    if html == ''
      $('.noEntrys').show()

    @$container.html(html)



class DreamfieldModel
  load: (filters={})->
    $.extend(filters, @filterOpts())
    $.getJSON("/dreamfield.json", {filters: filters}).promise()  
  updateFilters: ->
    @filters = []
    # get new filter values (will be .filter .value to target the span)
    $.each $('.trigger span.value'), (key, value) =>
      @filters.push($(value).text())  # XXX: data tightly coupled to display.
  filterOpts: ->
    # type: @filters[0]
    # friend: @filters[1]
    # starlight: @filters[2]

        