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
# $.Model 'Dreamcatcher.Models.Settings',{
# 
#   update: ( fieldName, data, success, error ) ->
#     log 'fieldName: '+ fieldName
#     log 'data: '+ data
#     data = parseInt data if fieldName == default_sharing_level
#     fieldname2 = "user[#{fieldName}]"
#     #if fieldName == 'default_sharing_level'
#     $.ajax {
#       type: 'put'
#       url: '/user.json'
#       dataType: 'json'
#       data: 
#         "user[#{fieldName}]": data       
#     }
#       
# },
# {}

# WORKING
$.Model 'Dreamcatcher.Models.Settings',{

  update: ( fieldName, data, success, error ) ->
    log 'fieldName: '+ fieldName
    log 'data: '+ data
    # data = parseInt data if fieldName == default_sharing_level
    
    if fieldName == 'default_sharing_level'
      $.ajax {
        type: 'put'
        url: '/user.json'
        dataType: 'json'
        data:
          'user[default_sharing_level]': parseInt data       
      }
      
    else if fieldName == 'default_landing_page'
      $.ajax {
        type: 'put'
        url: '/user.json'
        dataType: 'json'
        data:      
          'user[default_landing_page]': data
      }
},
{}

