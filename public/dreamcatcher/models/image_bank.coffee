$.Model 'Dreamcatcher.Models.ImageBank',{
  
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
      categories: ['all']
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

  getHtml: (path, data, success, error) ->
    $.ajax {
      url: "/#{path}"
      data: data
      dataType: 'html'
      success: @callback success
      error: error
    }

},
{}