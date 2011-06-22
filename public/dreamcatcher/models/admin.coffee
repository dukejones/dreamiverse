$.Model 'Dreamcatcher.Models.Admin',{
  
  loadUsers: ( params, success, error ) ->
    $.ajax {
      url: "/admin/users"
      type: 'get'
      data: params
      dataType:'json'
      success: success
      error: error
    } 

  loadBedsheets: ( params, success, error ) ->
    $.ajax {
      url: "/admin/bedsheets"
      type: 'get'
      data: params
      dataType:'json'
      success: success
      error: error
    }    
    
},
{}
