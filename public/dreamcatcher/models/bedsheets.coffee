$.Model.extend('Dreamcatcher.Models.Bedsheets',{  

  findAll: ( params, success, error ) ->
    $.ajax(
      url: '/images.json?section=Bedsheets'
      type: 'get'
      dataType: 'json'
      data: params
      success: @callback(['wrapMany',success])
      error: error
    )
    
    findByGenre: (genre, success, error ) ->
      $.ajax(
        url: "/images.json?section=Bedsheets&genre=#{genre}"
        type: 'get'
        dataType: 'json'
        data: {genre: genre}
        success: @callback(['wrapMany',success])
        error: error
      )
},
{})