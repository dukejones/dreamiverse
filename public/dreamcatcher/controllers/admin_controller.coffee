$.Controller 'Dreamcatcher.Controllers.Admin',
  
  init: -> 
    @page = 1   
    @totalUsers = parseInt $('#totalUsers').data 'id'
    @pageSize = $('#pageSize').data 'id'
    @totalPages = Math.ceil(@totalUsers / @pageSize)    
    @addPageLinks()
    @updateNav()
    @scope = 'None'
    @charts = new Dreamcatcher.Controllers.Charts $('#adminPage'),{parent: this}
   
        
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

  '.chart-select click': (el,ev) ->
    # the google.load command needs to be loaded in resources/google.charts.coffee so that it loads before this controller loads
    # @charts = new Dreamcatcher.Controllers.Charts $('#adminPage'),@scope,{parent: this}
    if ev.currentTarget.id is 'chart-a' then google.setOnLoadCallback @charts.getChartData('last_7_days_in_users')
    if ev.currentTarget.id is 'chart-b' then google.setOnLoadCallback @charts.getChartData('last_8_weeks_in_users')    
    if ev.currentTarget.id is 'chart-c' then google.setOnLoadCallback @charts.getChartData('last_6_months_in_users')
    if ev.currentTarget.id is 'chart-d' then google.setOnLoadCallback @charts.getChartData('last_7_days_in_entries')
    if ev.currentTarget.id is 'chart-e' then google.setOnLoadCallback @charts.getChartData('last_8_weeks_in_entries')
    if ev.currentTarget.id is 'chart-f' then google.setOnLoadCallback @charts.getChartData('last_6_months_in_entries')
    if ev.currentTarget.id is 'chart-g' then google.setOnLoadCallback @charts.getChartData('last_6_months_in_entry_types')
    
    