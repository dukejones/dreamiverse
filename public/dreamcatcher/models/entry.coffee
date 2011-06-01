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
    
  update: ( entryId, params, success, error ) ->
    $.ajax {
      url: "/entries/#{entryId}"
      type: 'put'
      dataType: 'json'
      data: params
      success: @callback success
      error: error
    }

},
{}