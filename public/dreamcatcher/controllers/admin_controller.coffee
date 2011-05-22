$.Controller 'Dreamcatcher.Controllers.Admin',
  model: Dreamcatcher.Models.Admin
  init: ->
    # @model = new Dreamcatcher.Models.Admin
    @totalUsers = parseInt $('#totalUsers').data 'id'
    @pageSize = $('#pageSize').data 'id'
    @totalPages = Math.ceil(@totalUsers / @pageSize)    
    @page = 1
    
    log 'loaded admin controller'
    $('#prevPage').hide() 

    num = 0
    while num < @totalPages
      num += 1
      $('#pages').append('<a href="#"' + num + ' id="userPage">' + num + '</a>')


  '#userPage click': (el,ev) ->
    log 'feh '+ el.text()
    @page = el.text()
    Dreamcatcher.Models.Admin.load @getParams(), @callback(@updateUsersPage)

  '#nextPage, #prevPage click': (el,ev) ->
    @page = 1 if !@page? 
    @page = if ev.currentTarget.id is 'nextPage' then @page += 1 else @page -= 1 
   
    log "#{ev.currentTarget.id} clicked, page: " + @page + ' totalPages: ' + @totalPages
    
    Dreamcatcher.Models.Admin.load @getParams(), @callback(@updateUsersPage)
    

    # $('.total#page').html(@page)  


  updateUsersPage: (json) ->  
    $("#userList").hide("slide", { direction: "right" }, 200)     
    $("#userList").html(json.html)
    $("#userList").show("slide", { direction: "left" }, 200);
   
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
       