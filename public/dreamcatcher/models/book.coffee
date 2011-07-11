$.Model.extend 'Book', {
  
  new: ( attrs, success, error ) ->
    $.ajax {
      url: '/books/new'
      type: 'get'
      dataType: 'html'
      data: attrs
      success: @callback success
      error: error
    }
    
  create: ( attrs, success, error ) ->
    $.ajax {
      url: "/books"
      type: 'post'
      dataType: 'json'
      data: attrs
      success: @callback success
      error: error
    }
    
  update: ( id, attrs, success, error ) ->
    $.ajax {
      url: "/books/#{id}"
      type: 'put'
      dataType: 'json'
      data: attrs
      success: @callback success
      error: error
    }

  get: ( attrs, success, error ) ->
    $.ajax {
      url: '/books'
      type: 'get'
      dataType: 'html'
      data: attrs
      success: @callback success
      error: error
    }
    
  show: ( id, attrs, success, error ) ->
    $.ajax {
      url: "/books/#{id}"
      type: 'get'
      dataType: 'html'
      data: attrs
      success: @callback success
      error: error
    }
    
  destroy: ( id, success, error ) ->
    $.ajax {
      url: "/books/#{id}"
      type: 'delete'
      dataType: 'json'
      success: @callback success
      error: error
    }

},
{}