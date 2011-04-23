$.Model 'Dreamcatcher.Models.Settings',{

  update: ( sharingLevel, success, error ) ->
    $.ajax {
      type: 'put'
      url: '/user.json'
      dataType: 'json'
      data:
        'user[default_sharing_level]': parseInt sharingLevel
    }

},
{}
