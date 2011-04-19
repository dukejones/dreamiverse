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

  loadNextPage: (showAll=false)->
    return if @currentlyLoading
    $('#pagination .next').addClass('loading')
    @page += 1
    
    log('page: ' + @page)
    @dreamfield.load({ page: @page, show_all: showAll }).then (data)=>
      @clear()
      if !data.html? || data.html == ""
        $('.next').parent().hide()
      
      if showAll
        $('.next').parent().hide()

      @$container.before(data.html)

      
  update: (html) ->
    @clear()
    if html == ''
      $('.noEntrys').show()

    @$container.html(html)



class DreamfieldModel
  load: (filters={})->
    $.getJSON("/entries.json", {filters: filters}).promise()


