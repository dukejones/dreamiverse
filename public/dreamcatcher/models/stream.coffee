$.Model 'Dreamcatcher.Models.Stream',
    
  load: (data, success, error ) ->
    $.ajax {
      url: '/stream.json'
      type: 'get'
      data: data
      dataType: 'json'
      success: @callback success
      error: error
    }