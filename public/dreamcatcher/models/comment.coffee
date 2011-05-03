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
      success: @callback success
      error: error
      data: {comment: attrs}
    }
    
  delete: ( entryId, commentId, success, error ) ->
    $.ajax {
      url: "/entries/#{entryId}/comments/#{commentId}"
      type: 'delete'
      dataType: 'json'
      success: success
      error: error
    }
    
  showEntry: ( entryId, success, errpr ) ->
    $.ajax {
      url: "/entries/#{entryId}"
      type: 'get'
      dataType: 'json'
      success: success
    }

},
{}