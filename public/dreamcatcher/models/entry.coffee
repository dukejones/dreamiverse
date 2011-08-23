$.Model.extend 'Entry', {
    
  create: (params) ->
    $.ajax {
      url: '/entries'
      type: 'post'
      dataType: 'json'
      data: params
    }
  
  show: (id, success) ->
    $.get "/entries/#{id}", @callback success
    
  next: (id, success) ->
    $.get "/entries/#{id}/next", @callback success
  
  previous: (id, success) ->
    $.get "/entries/#{id}/previous", @callback success

  new: (params, success, error) ->
    $.get '/entries/new', @callback success
    
  edit: (id, success) ->
    $.get "/entries/#{id}/edit", @callback success
    
  index: (username, success) ->
    params = {username: username} if username?
    $.get "/entries", params, @callback success
    
  update: ( entryId, params, success, error ) ->
    $.ajax {
      url: "/entries/#{entryId}"
      type: 'put'
      dataType: 'json'
      data: params
      success: @callback success
      error: error
    }
  ###
  showField: ( params, success, error ) ->
    $.ajax {
      url: '/entries/show_field'
      type: 'get'
      dataType: 'html'
      data: params
      success: @callback success
      error: error
    }
  ###
    
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