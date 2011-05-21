$.Model 'Dreamcatcher.Models.Admin',{
  
  load: ( params, success, error ) ->
    $.ajax {
      url: "/admin"
      type: 'get'
      data: params
      dataType:'json'
      success: success
      error: error
    } 
    
},
{}
