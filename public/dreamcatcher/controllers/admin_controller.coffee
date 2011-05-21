$.Controller 'Dreamcatcher.Controllers.Admin',

  init: ->
    @page = 1
    log 'loaded admin controller'
    
  '#next click': (el) ->
    log 'next clicked'
    @updateUserPage
    
  updateUsersPage:
    params['page'] = @page
    # Dreamcatcher.Models.Admin.load @page,@callback(updateUsersPage)
    @admin.load @page,@callback(updateUsersPage)
    $("#userList").html(""). 
    