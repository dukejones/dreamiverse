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
     
},
{}
