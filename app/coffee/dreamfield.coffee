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
    # @$container = $('#entryField .matrix')
    @$container = $('#paginationAnchor').find('.thumb-2d').last()

    $('.next').click( (event) =>
      @loadNextPage()
      return false
    )
    
  clear: ->
    $('#pagination .next').removeClass('loading')

  loadNextPage: ->
    return if @currentlyLoading
    @currentlyLoading = true
    @clear()
    $('#pagination .next').addClass('loading')
    @page += 1
    @dreamfield.load({ page: @page }).then (data)=>
      @clear()
      @currentlyLoading = false
      if !data.html? || data.html == ""
        @currentlyLoading = true # No more entries to load.
        $('.next').parent().hide()

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

        