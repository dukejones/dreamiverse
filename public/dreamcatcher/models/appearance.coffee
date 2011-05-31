$.Model 'Dreamcatcher.Models.Appearance', {

  update: ( id, params, success, error ) ->
    $.ajax {
      type: 'post'
      url: if id? then "/entries/#{id}/set_view_preferences" else "/user/set_view_preferences"
      data: params
      success: success
      error: error
    }

},
{}