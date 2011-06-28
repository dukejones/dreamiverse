$.Model 'Dreamcatcher.Models.User',{

  #todo: copied from settings model - refactor later
  update: ( params, success, error ) ->
    $.ajax {
      type: 'put'
      url: '/user.json'
      dataType: 'json'
      data: params
      success: success
      error: error
    }
    
  setViewPreferences: ( params, success, error ) ->
    $.ajax {
      type: 'post'
      url: "/user/set_view_preferences"
      data: params
      success: success
      error: error
    }

  follow: ( params, success, error ) ->
    $.ajax {
      type: 'put'
      url: "/#{params.username}/follow"
      dataType: 'json'
      data: params
      success: success
      error: error
    }
    
  unfollow: ( params, success, error ) ->
    $.ajax {
      type: 'put'
      url: "/#{params.username}/unfollow"
      dataType: 'json'
      data: params
      success: success
      error: error
    }      
    
  contextPanel: ( params, success ) ->
    $.get '/user/context_panel', params, @callback success
     
},
{}
