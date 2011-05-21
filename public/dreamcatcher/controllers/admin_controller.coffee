$.Controller 'Dreamcatcher.Controllers.Admin',
  # model: Dreamcatcher.Models.Admin
  init: ->
    @model = new Dreamcatcher.Models.Admin
    @page = 1
    log 'loaded admin controller'

  '#nextPage, #prevPage click': (el,ev) ->
    @currentPage = $('#currentPage').data 'id'
    log 'ev.currentTarget.id: ' + ev.currentTarget.id
    @page = if ev.currentTarget.id is 'nextPage' then @page += 1 else @page -= 1
    @page = 1 if !@page? 
   
    log "#{ev.currentTarget.id} clicked page: " + @page + 'currentPage: ' + @currentPage
    $('#userList .spinner').show()
    Dreamcatcher.Models.Admin.load @getParams(), @callback(@updateUsersPage)
  
  
  updateUsersPage: (json) ->  
    $("#userList").hide("slide", { direction: "right" }, 1000)     
    $("#userList").html(json.html)
    $("#userList").show("slide", { direction: "left" }, 1000);
    # $("#userList .spinner").hide()
    
  getParams: ->
    page: @page
       