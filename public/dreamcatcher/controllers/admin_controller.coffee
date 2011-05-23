$.Controller 'Dreamcatcher.Controllers.Admin',
  
  init: -> 
    @page = 1   
    @totalUsers = parseInt $('#totalUsers').data 'id'
    @pageSize = $('#pageSize').data 'id'
    @totalPages = Math.ceil(@totalUsers / @pageSize)    
    @addPageLinks()
    
    log "page: #{@page} totalUsers: #{@totalUsers} pageSize: #{@pageSize} totalPages: #{@totalPages}"  
    
        
  updateUsersPage: (json) ->  
    $("#userList").html(json.html)
    # @updateNav()
    $("#userList .spinner").hide()

  getParams: ->
    page: @page
  
  # Show or hide next/prev buttons
  updateNav: ->
    if @page > 1 
     $('#prevPage').show() 
    else 
     $('#prevPage').hide()

    if @page < @totalPages    
      $('#nextPage').show()
    else
      $('#nextPage').hide()
  
  # Add numbered page links  
  addPageLinks: ->
    num = 0
    while num < @totalPages
      num += 1
      $('#pages').append @view 'page_number', {page: num}    

        
  # Dom listeners
  '#userPage click': (el,ev) ->
    @page = parseInt el.text()
    $("#userList .spinner").show()
    Dreamcatcher.Models.Admin.load @getParams(), @updateUsersPage
    @updateNav()

  '#nextPage, #prevPage click': (el,ev) ->
    @page = 1 if !@page? 
    @page = if ev.currentTarget.id is 'nextPage' then @page += 1 else @page -= 1 
    $("#userList .spinner").show()
    Dreamcatcher.Models.Admin.load @getParams(), @updateUsersPage  
    @updateNav()     