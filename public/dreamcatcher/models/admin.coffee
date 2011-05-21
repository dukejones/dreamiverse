$.Model 'Dreamcatcher.Models.Admin',{
  
  load: ( params, success, error ) ->
    $.ajax {
      url: "/admin/user_list"
      type: 'get'
      data: params
      dataType:'json'
      success: success
      error: error
    } 
    
},
{}
