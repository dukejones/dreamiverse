$.Model 'Dreamcatcher.Models.Entry', {
  
  getHtml: ( params, success, error ) ->
    $.ajax {
      url: '/entries/show_entry'
      type: 'get'
      dataType: 'html'
      data: params
      success: @callback success
      error: error
    }

},
{}