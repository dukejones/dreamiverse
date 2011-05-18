$.Model 'Dreamcatcher.Models.Settings',{

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
