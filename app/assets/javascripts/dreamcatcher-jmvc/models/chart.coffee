$.Model 'Dreamcatcher.Models.Chart',{
  
  loadSimpleLineChart: ( params, success, error ) ->
    $.ajax {
      url: "/admin/line_chart"
      type: 'get'
      data: params
      dataType:'json'
      success: success
      error: error
    }
      
  loadPieChart: ( params, success, error ) ->
    $.ajax {
      url: "/admin/pie_chart"
      type: 'get'
      data: params
      dataType:'json'
      success: success
      error: error
    }  
  
},
{}
