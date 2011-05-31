$.Model 'Dreamcatcher.Models.Book', {
  
  getHtml: ( path, params, success, error ) ->
    $.ajax {
      url: '/books/'+path
      type: 'get'
      dataType: 'html'
      data: params
      success: @callback success
      error: error
    }
    
  create: ( attrs, success, error ) ->
    $.ajax {
      url: "/books"
      type: 'post'
      dataType: 'json'
      success: @callback success
      error: error
      data: attrs
    }

},
{}