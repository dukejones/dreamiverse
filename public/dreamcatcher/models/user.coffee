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
     
},
{}
