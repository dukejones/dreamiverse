$.Model 'Dreamcatcher.Models.Image',{
  
  get: (imageId, data, success, error) ->
    $.ajax {
      url: "/images/#{imageId}.json"
      type: 'get'
      dataType: 'json'
      data: data
      success: @callback success
      error: error
    }
  
  findByIds: ( imageIds, data, success, error ) ->
    $.ajax {
      url: "/images.json?ids=#{imageIds}"
      type: 'get'
      dataType: 'json'
      data: data
      success: @callback success
      error: error
    }
  
  search: ( data, success, error ) ->
    $.ajax {
      url: "/images.json"
      type: 'get'
      dataType: 'json'
      data: data
      success: @callback success
      error: error
    }

  update: ( imageId, data, success, error ) ->
    $.ajax {
      url: "/images/#{imageId}.json"
      type: 'put'
      contentType: 'application/json'
      data: JSON.stringify(data)
      dataType: 'json'
      success: success
      complete: =>
        @publish 'updated', imageId
      error: error
    }
    
  updateField: (data, success, error) ->
    $.ajax {
      url: "/images/updatefield.json"
      type: 'post'
      contentType: 'application/json'
      data: JSON.stringify(data)
      dataType: 'json'
      success: success
      error: error
    }
    
  disable: ( imageId, data, success, error) ->
    $.ajax {
      url: "/images/#{imageId}/disable.json"
      type: 'post'
      contentType: 'application/json'
      dataType: 'json'
      data: data
      success: @callback success
      error: error
    }
},
{}