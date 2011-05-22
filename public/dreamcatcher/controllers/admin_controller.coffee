$.Controller 'Dreamcatcher.Controllers.Admin',
  
  model: Dreamcatcher.Models.Admin
  
  init: ->
    # @model = new Dreamcatcher.Models.Admin
    @totalUsers = parseInt $('#totalUsers').data 'id'
    @pageSize = $('#pageSize').data 'id'
    @totalPages = Math.ceil(@totalUsers / @pageSize)    
    @page = 1
    
    $('#prevPage').hide() 

    num = 0
    while num < @totalPages
      num += 1
      $('#pages').append @view 'page_number', {page: num}
     

  '#userPage click': (el,ev) ->
    @page = el.text()
    Dreamcatcher.Models.Admin.load @getParams(), @updateUsersPage

  '#nextPage, #prevPage click': (el,ev) ->
    @page = 1 if !@page? 
    @page = if ev.currentTarget.id is 'nextPage' then @page += 1 else @page -= 1 
    .spinner.show()
    Dreamcatcher.Models.Admin.load @getParams(), @updateUsersPage

  updateUsersPage: (json) ->  
    $("#userList").html(json.html)
   
    if @page > 1 
      $('#prevPage').show() 
    else 
      $('#prevPage').hide()
               
    $('#nextPage').show()
    $('#nextPage').hide() if @page >= @totalPages    
    log "page: #{@page} totalPages: #{@totalPages}"
    # $("#userList .spinner").hide()
    
    
  getParams: ->
    page: @page
       