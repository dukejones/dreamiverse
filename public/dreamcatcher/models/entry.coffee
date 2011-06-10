$.Model.extend 'Dreamcatcher.Models.Entry', {
  
  
  create: (params) ->
    $.ajax {
      url: '/entries'
      type: 'post'
      dataType: 'json'
      data: params
    }
  
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
        
  edit: ( params, success, error ) ->
    $.ajax {
      url: "/entries/edit_entry"
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

    
  showContext: ( params, success, error ) ->
    $.ajax {
      url: '/entries/show_context'
      type: 'get'
      dataType: 'html'
      data: params
      success: @callback success
      error: error
    }
    
  showStream: ( params, success, error ) ->
    $.ajax {
      url: '/entries/show_stream'
      type: 'get'
      dataType: 'html'
      data: params
      success: @callback success
      error: error
    }

  showField: ( params, success, error ) ->
    $.ajax {
      url: '/entries/show_field'
      type: 'get'
      dataType: 'html'
      data: params
      success: @callback success
      error: error
    }
    
  setViewPreferences: ( entryId, params, success, error ) ->
    $.ajax {
      type: 'post'
      url: "/entries/#{entryId}/set_view_preferences"
      dataType: 'json'
      data: params
      success: success
      error: error
    }
},
{}