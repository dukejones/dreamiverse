$.Model 'Dreamcatcher.Models.Tag',{

  create: ( params, success, error ) ->
    $.ajax {
      type: 'post'
      url: '/tags'
      dataType: 'json'
      data: params
      success: success
      error: error
    }
    
  delete: (params, success, error) ->
    $.ajax {
      type: 'delete'
      url: '/tags/what'
      data: params
      success: success
      error: error
    } 
     
},
{}
