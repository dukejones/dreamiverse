$.Model 'Dreamcatcher.Models.Entry', {
  
  show: ( params, success, error ) ->
    $.ajax {
      url: '/entries/show_entry'
      type: 'get'
      dataType: 'html'
      data: params
      success: @callback success
      error: error
    }
    
  new: ( params, success, error ) ->
    $.ajax {
      url: '/entries/new_entry'
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