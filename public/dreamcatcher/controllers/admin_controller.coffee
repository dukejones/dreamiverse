$.Controller 'Dreamcatcher.Controllers.Admin',
  
  init: -> 
    @page = 1
    @bedsheetsLoaded = false   
    @totalUsers = parseInt $('#totalUsers').data 'id'
    @pageSize = $('#pageSize').data 'id'
    @totalPages = Math.ceil(@totalUsers / @pageSize)    
    @addPageLinks()
    @updateNav()
    @scope = 'None'
    @charts = new Dreamcatcher.Controllers.Charts $('#adminPage'),{parent: this}
    @charts.getLineChartData('last 7 days in users','user')
    @charts.getLineChartData('last 7 days in entries','entry')
   
   
  updateUsersPage: (json) ->  
    $('#userList').html(json.html)
    # @updateNav()
    $('#allUsersIcon').show()
    $('#pageLoading').hide()

  
  # Show or hide next/prev buttons
  updateNav: ->
    if @page > 1 
     $('#prevPage').show()
     $('#prevPageEnd').hide()
    else 
     $('#prevPage').hide()
     $('#prevPageEnd').show()

    if @page < @totalPages    
      $('#nextPage').show()
      $('#nextPageEnd').hide()
    else
      $('#nextPage').hide()
      $('#nextPageEnd').show()
      
    $(".userPage").css("text-decoration", "none") # reset
    $("#userPage-#{@page}").css("text-decoration", "underline")   
  
  displayBedsheets: ( bedsheetsLoaded, json) ->
    log "bedsheetsLoaded #{bedsheetsLoaded}"   
    $('#bedsheet-nodes').toggle('showOrHide')
    
    unless @bedsheetsLoaded
      $('#bedsheet-nodes').html(json.html) unless @bedsheetsLoaded
      @bedsheetsLoaded = true
    
  # Add numbered page links  
  addPageLinks: ->
    num = 0
    while num < @totalPages
      num += 1
      $('#pages').append @view 'page_number', {page: num}    

  # Generate model options   
  getOptions: ->
    filters: {
      page: @page
      order_by: $('#user-filter').val()
    }

 
  # Dom listeners
  '.userPage click': (el,ev) ->
    @page = parseInt el.text()
    $('#allUsersIcon').hide()
    $('#pageLoading').show()
    Dreamcatcher.Models.Admin.loadUsers @getOptions(), @updateUsersPage
    @updateNav()     

  '#nextPage, #prevPage click': (el,ev) ->
    @page = 1 if !@page? 
    @page = if ev.currentTarget.id is 'nextPage' then @page += 1 else @page -= 1 
    $('#allUsersIcon').hide()
    $('#pageLoading').show()
    Dreamcatcher.Models.Admin.loadUsers @getOptions(), @updateUsersPage  
    @updateNav() 
    
  '#user-filter change': (el) ->
    log 'user-filter changed to: ' + el.val()
    @page = 1 
    $('#pageLoading').show()
    Dreamcatcher.Models.Admin.loadUsers @getOptions(), @updateUsersPage  
    @updateNav()    

  '.button click': (el,ev) ->
    # the google.load command needs to be loaded in resources/google.charts.coffee so that it loads before this controller loads
    # @charts = new Dreamcatcher.Controllers.Charts $('#adminPage'),@scope,{parent: this}
    if ev.currentTarget.id is 'users-chart_a' then google.setOnLoadCallback @charts.getLineChartData('last 7 days in users','user')
    if ev.currentTarget.id is 'users-chart_b' then google.setOnLoadCallback @charts.getLineChartData('last 8 weeks in users','user')    
    if ev.currentTarget.id is 'users-chart_c' then google.setOnLoadCallback @charts.getLineChartData('last 6 months in users','user')
    if ev.currentTarget.id is 'users-chart_d' then google.setOnLoadCallback @charts.getPieChartData('top 32 users by entries','user')
    if ev.currentTarget.id is 'users-chart_e' then google.setOnLoadCallback @charts.getPieChartData('top 32 users by starlight','user')
    if ev.currentTarget.id is 'users-chart_f' then google.setOnLoadCallback @charts.getPieChartData('seed codes usages','user')

    if ev.currentTarget.id is 'entries-chart_g' then google.setOnLoadCallback @charts.getLineChartData('last 7 days in entries','entry')
    if ev.currentTarget.id is 'entries-chart_h' then google.setOnLoadCallback @charts.getLineChartData('last 8 weeks in entries','entry')
    if ev.currentTarget.id is 'entries-chart_i' then google.setOnLoadCallback @charts.getLineChartData('last 6 months in entries','entry')
    if ev.currentTarget.id is 'entries-chart_j' then google.setOnLoadCallback @charts.getLineChartData('last 6 months in entry types','entry')
    if ev.currentTarget.id is 'entries-chart_k' then google.setOnLoadCallback @charts.getLineChartData('last 6 months in comments','entry')
    if ev.currentTarget.id is 'entries-chart_l' then google.setOnLoadCallback @charts.getPieChartData('top 32 tags','entry')

    

    
  '#bedsheetsHeader click': (el,ev) ->
    Dreamcatcher.Models.Admin.loadBedsheets @getOptions(), @callback('displayBedsheets',@bedsheetsLoaded)


    
    