$.Model 'Dreamcatcher.Models.Image',{
  
  get: (imageId, data, success, error) ->
    $.ajax {
      url: "/images/#{imageId}"
      type: 'get'
      dataType: 'json'
      data: data
      success: @callback success
      error: error
    }
  
  findByIds: ( imageIds, data, success, error ) ->
    $.ajax {
      url: "/images?ids=#{imageIds}"
      type: 'get'
      dataType: 'json'
      data: data
      success: @callback success
      error: error
    }
  
  search: ( data, success, error ) ->
    $.ajax {
      url: "/images"
      type: 'get'
      dataType: 'json'
      data: data
      success: @callback success
      error: error
    }

  update: ( imageId, data, success, error ) ->
    $.ajax {
      url: "/images/#{imageId}"
      type: 'put'
      contentType: 'application/json'
      data: JSON.stringify(data)
      dataType: 'json'
      success: success
      complete: =>
        @publish 'updated', imageId
      error: error
    }
    
  updatefield: (data, success, error) ->
    $.ajax {
      url: "/images/updatefield"
      type: 'post'
      contentType: 'application/json'
      data: JSON.stringify(data)
      dataType: 'json'
      success: success
      error: error
    }
    
  disable: ( imageId, data, success, error) ->
    $.ajax {
      url: "/images/#{imageId}/disable"
      type: 'post'
      contentType: 'application/json'
      dataType: 'json'
      data: data
      success: @callback success
      error: error
    }
    
  artists: (data, success, error) ->
    $.ajax {
      url: "/images/artists"
      data: data
      dataType: 'html'
      success: @callback success
      error: error
    }
    
  albums: (data, success, error) ->
    $.ajax {
      url: "/images/albums"
      data: data
      dataType: 'html'
      success: @callback success
      error: error
    }
    
    
  getHtml: (path, data, success, error) ->
    $.ajax {
      url: "/#{path}"
      data: data
      dataType: 'html'
      success: @callback success
      error: error
    }
    
  
  
  #json constants  
    
  attributes: ['type', 'category', 'genre', 'title', 'album', 'artist', 'location', 'year', 'notes', 'date', 'user', 'geotag', 'tags']

  types: [
    {
      name: 'bedsheets'
      categories: ['colors', 'textures', 'space', 'earth', 'city', 'nature', 'cultural', 'nightmare', 'water', 'landscape']
    }
    {
      name: 'library'
      categories: ['paintings', 'digital', 'fantasy', 'visionary', 'graphics', 'europe', 'eurasia', 'asia', 'americas', 'africa', 'australia', 'people', 'places', 'things', 'concept', 'animals']
    }
    {
      name: 'user uploaded'
      categories: ['avatars']
    }
    {
      name: 'emotions'
      categories: ['animals', 'smilies', 'shapes', 'plants', 'powers', 'eyes', 'weather', 'hands', 'classics']
    }
    {
      name: 'book covers'
      categories: ['all']
    }
    {
      name: 'prima materia'
      categories: ['symbol', 'illustration', 'photo', '3d']
    }
  ]

  genres: ['photo', 'art', 'design']


},
{}