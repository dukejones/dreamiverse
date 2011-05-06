# ORIGINAL
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

# IDEAL
$.Model 'Dreamcatcher.Models.Settings',{

  update: ( params, success, error ) ->
    $.ajax {
      type: 'put'
      url: '/user.json'
      dataType: 'json'
      data: params     
    }
     
},
{}
