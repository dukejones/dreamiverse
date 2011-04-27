$.Model 'Dreamcatcher.Models.Comment',{
  
  findComments: ( id, params, success, error ) ->
    $.ajax {
      url: "/entries/#{id}/comments"
      type: 'get'
      dataType: 'json'
      data: params
      success: @callback success
      error: error
    }

},
{}