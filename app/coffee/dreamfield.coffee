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
    @$container = $('#pagination')
    
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
      
      @$container = $('.matrix')
    
    log('page: ' + @page)
    @dreamfield.load({ page: @page }).then (data)=>
      @clear()
      @currentlyLoading = false
      if !data.html? || data.html == ""
        @currentlyLoading = true # No more entries to load.
        $('.next').parent().hide()
      
      if showAll
        $('.matrix').find('.thumb-2d').hide() # clear existing thumbs to make room for all
        $('.next').parent().hide()
        @$container.append(data.html) 
      else
        @$container.before(data.html)

      
  update: (html) ->
    @clear()
    if html == ''
      $('.noEntrys').show()

    @$container.html(html)



class DreamfieldModel
  load: (filters={})->
    $.getJSON("/entries.json", {filters: filters}).promise()


        