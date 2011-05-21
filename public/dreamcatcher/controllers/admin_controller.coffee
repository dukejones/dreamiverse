$.Controller 'Dreamcatcher.Controllers.Admin',
  model: Dreamcatcher.Models.Admin
  init: ->
    @page = 1
    log 'loaded admin controller'
    # @updateUserPage

  '#nextPage click': ->
    @currentPage = $('#currentPage').data 'id'
    @page += 1
   
    log 'next clicked page: ' + @page + 'currentPage: ' + @currentPage
    # @updateUsersPage()
    @model.load @getParams(), @callback(@updateUsersPage)
    
  updateUsersPage: (json) ->       
    $("#userList").replaceWith(json.html)
    
  getParams: ->
    page: @page
       