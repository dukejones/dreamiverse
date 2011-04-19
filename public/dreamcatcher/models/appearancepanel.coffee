$.Model.extend('Dreamcatcher.Models.AppearancePanel',{  
  findAllBedsheets: ( params, success, error ) ->
    $.ajax(
      url: '/images.json?section=Bedsheets'
      type: 'get'
      dataType: 'json'
      data: params
      success: @callback(['wrapMany',success])
      error: error
    )

  updateEntryView: ( id, params, success, error ) ->
    $.ajax(
      url: "/entries/"+id+"/set_view_preferences"
      type: 'post'
      dataType: 'json'
      data: params
      success: @callback(['wrapMany',success])
      error: error
    )

  updateUserView: ( params, success, error )->
    $.ajax(
      url: "/user/set_view_preferences"
      type: 'post'
      dataType: 'json'
      data: params
      success: success
      error: error
  )
},
{})