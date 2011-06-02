$.Model 'Dreamcatcher.Models.Chart',{
  
  loadLineChart: ( params, success, error ) ->
    $.ajax {
      url: "/admin/load_line_chart"
      type: 'get'
      data: params
      dataType:'json'
      success: success
      error: error
    }

  loadPieChart: ( params, success, error ) ->
    $.ajax {
      url: "/admin/load_pie_chart"
      type: 'get'
      data: params
      dataType:'json'
      success: success
      error: error
    }  
  
},
{}
