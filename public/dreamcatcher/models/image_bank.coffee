$.Model 'Dreamcatcher.Models.ImageBank',{

  update: ( imageId, data, success, error ) ->
    $.ajax {
      url: "/images/#{imageId}.json"
      type: 'put'
      contentType: 'application/json'
      data: JSON.stringify(data)
      dataType: 'json'
      complete: success
      error: error
    }
  
  findImagesById: ( imageIds, data, success, error ) ->
    $.ajax {
      url: "/images.json?ids=#{imageIds}"
      type: 'get'
      dataType: 'json'
      data: data
      success: @callback success
      error: error
    }
    
  getImage: (imageId, data, success, error) ->
    $.ajax {
      url: "/images/#{imageId}.json"
      type: 'get'
      dataType: 'json'
      data: data
      success: @callback success
      error: error
    }
  
},
{}