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
     
},
{}
