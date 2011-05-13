$.Model 'Dreamcatcher.Models.Bedsheet',{
  
  findAll: ( params, success, error ) ->
    params.ids_only = true
    $.ajax {
      url: '/images.json?section=Bedsheets'
      type: 'get'
      dataType: 'json'
      data: params
      success: @callback success
      error: error
    }

},
{}