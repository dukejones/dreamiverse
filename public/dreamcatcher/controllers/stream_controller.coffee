$.Controller 'Dreamcatcher.Controllers.Stream',

  init: ->
    
    $('#entry-filter, #users-filter').change( (event) =>
      @stream.load().then (data) =>
        @streamView.update(data.html)
    )
    
  