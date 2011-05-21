$.Controller 'Dreamcatcher.Controllers.Admin',
  model: Dreamcatcher.Models.Admin
  init: ->
    @page = 1
    log 'loaded admin controller'
    # @updateUserPage

  '#nextPage click': ->
    @page += 1
    log 'next clicked page: ' + @page
    # @updateUsersPage()
    @model.load @getParams(),@callback(@updateUsersPage)
    
  updateUsersPage: (json) ->       
    $("#userList").html(json.html)
    log 'json: ' + json.html
    
  getParams: ->
    page: @page
       