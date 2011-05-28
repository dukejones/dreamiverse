$.Model 'Dreamcatcher.Models.Entry', {
  
  getHtml: ( params, success, error ) ->
    $.ajax {
      url: '/entries/showPartial'
      type: 'get'
      dataType: 'html'
      data: params
      success: @callback success
      error: error
    }

},
{}