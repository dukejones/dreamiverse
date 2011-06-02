$.Model 'Dreamcatcher.Models.Admin',{
  
  loadUsers: ( params, success, error ) ->
    $.ajax {
      url: "/admin/user_list"
      type: 'get'
      data: params
      dataType:'json'
      success: success
      error: error
    } 

  loadBedsheets: ( params, success, error ) ->
    $.ajax {
      url: "/admin/load_bedsheets"
      type: 'get'
      data: params
      dataType:'json'
      success: success
      error: error
    }    
    
},
{}
