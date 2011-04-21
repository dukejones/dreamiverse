$.Model.extend('Dreamcatcher.Models.Bedsheet',{

  #TODO: refine image.json, so it just returns ids!

  findAll: ( params, success, error ) ->
    $.ajax(
      url: '/images.json?section=Bedsheets'
      type: 'get'
      dataType: 'json'
      data: params
      success: @callback(['wrapMany',success])
      error: error
    )

},
{})