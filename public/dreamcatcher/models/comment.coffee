$.Model 'Dreamcatcher.Models.Comment',{
  
  findEntryComments: ( entryId, params, success, error ) ->
    $.ajax {
      url: "/entries/#{entryId}/comments"
      type: 'get'
      dataType: 'json'
      data: params
      success: @callback success
      error: error
    }
    
  create: ( entryId, attrs, success, error ) ->
    $.ajax {
      url: "/entries/#{entryId}/comments"
      type: 'post'
      dataType: 'json'
      success: success
      error: error
      data: attrs
    }
    
  delete: ( entryId, commentId, attrs, success, error ) ->
    $.ajax {
      url: "/entries/#{entryId}/comments/#{commentId}"
      type: 'delete'
      dataType: 'json'
      success: success
      error: error
      data: attrs
    }

},
{}