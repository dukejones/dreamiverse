$.Model.extend('Dreamcatcher.Models.Appearance',{

  update: ( id, params, success, error ) ->
    url = "/user/set_view_preferences"
    url = "/entries/#{id}/set_view_preferences" if id? #entry view is id is not null
    $.ajax(
      type: 'post'
      url: url
      data: params
      success: success
      error: error
    )
},
{})