# $.Model 'Dreamcatcher.Models.Settings',{
# 
#   update: ( sharingLevel, success, error ) ->
#     $.ajax {
#       type: 'put'
#       url: '/user.json'
#       dataType: 'json'
#       data:
#         'user[default_sharing_level]': parseInt sharingLevel
#     }
# 
# },
# {}

$.Model 'Dreamcatcher.Models.Settings',{

  update: ( fieldName, data, success, error ) ->
    log 'fieldName: '+ fieldName
    log 'data:'+ data
    # data = parseInt data if fieldName == default_sharing_level
    $.ajax {
      type: 'put'
      url: '/user.json'
      dataType: 'json'
      data: 'user[default_sharing_level]': parseInt data if fieldName == 'default_sharing_level'
      data: 'user[default_landing_page]': data if fieldName == 'default_landing_page'
      # data: 'user['+ fieldName +']': data
    }

},
{}