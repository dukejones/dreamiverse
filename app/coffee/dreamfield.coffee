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
    @$container = $('#entryField .matrix')
    
    # adds the loading wheel
    $('.filterList').click( (event) =>
      $(event.currentTarget).parent().find('.trigger').addClass('loading')
      return false
    )
    $('.next').click( (event) =>
      @loadNextPage()
    )
    
  clear: ->
    $('#noMoreEntries, .noEntrys, #nextPageLoading').hide()

  loadNextPage: ->
    return if @currentlyLoading
    @currentlyLoading = true
    @clear()
    $('#nextPageLoading').show()
    @page += 1
    @dreamfield.load({ page: @page }).then (data)=>
      @clear()
      @currentlyLoading = false
      if !data.html? || data.html == ""
        @currentlyLoading = true # No more entries to load.
        $('#noMoreEntries').show()

      @$container.append(data.html)
      
  update: (html) ->
    @clear()
    if html == ''
      $('.noEntrys').show()

    # after data loads into view, remove the loading spinner
    # $('#streamContextPanel .trigger').removeClass('loading')
    $('.filterList' .trigger).remoteClass('loading')

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

        