$.Model 'Dreamcatcher.Models.Chart',{
  
  loadChart: ( params, success, error ) ->
    $.ajax {
      url: "/admin/charts"
      type: 'get'
      data: params
      dataType:'json'
      success: success
      error: error
    }
    
},
{}
