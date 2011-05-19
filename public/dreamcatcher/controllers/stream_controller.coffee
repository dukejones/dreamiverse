$.Controller 'Dreamcatcher.Controllers.Stream',

  model: Dreamcatcher.Models.Stream

  init: ->
    @container = $('#entryField .matrix')

  '#entry-filter, #users-filter change': (el) ->
    filters = {
      type: $('#entry-filter').val()
      users: $('#users-filter').val()
    }
    @model.update {filters: filters}, @callback('updateStream')
    
  updateStream: (html) ->
    @container.html html
    