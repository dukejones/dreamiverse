$.Model 'Dreamcatcher.Models.Book', {
  
  new: ( params, success, error ) ->
    $.ajax {
      url: '/books/new'
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
    
  update: ( id, data, success, error ) ->
    $.ajax {
      url: "/books/#{id}"
      type: 'put'
      dataType: 'json'
      success: @callback success
      error: error
      data: data
    }

  get: ( attrs, success, error ) ->
    $.ajax {
      url: '/books'
      type: 'get'
      dataType: 'html'
      success: @callback success
      error: error
      data: attrs
    }
    
  show: (id, attrs, success, error ) ->
    $.ajax {
      url: "/books/#{id}"
      type: 'get'
      dataType: 'html'
      success: @callback success
      error: error
      data: attrs
    }

},
{}