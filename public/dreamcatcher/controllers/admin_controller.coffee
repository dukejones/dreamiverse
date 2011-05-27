$.Controller 'Dreamcatcher.Controllers.Admin',
  
  init: -> 
    @page = 1   
    @totalUsers = parseInt $('#totalUsers').data 'id'
    @pageSize = $('#pageSize').data 'id'
    @totalPages = Math.ceil(@totalUsers / @pageSize)    
    @addPageLinks()
    @updateNav()
    google.setOnLoadCallback @getChartData()

    
        
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

  # Generate model options   
  getChartOptions: (@title) ->
    title: @title 

  countObj: (obj) ->
    i = 0
    for x of obj
      if obj.hasOwnProperty(x)
        i++
    return i
      
  drawChart: (json) ->
    log json.data
    log json.data[0]['label']['val']

    data = new google.visualization.DataTable()
    data.addColumn('string', 'Date')
    data.addColumn('number', 'New Users')
        
    keys = [6..0]
    data.addRows(keys.length) 
    for num in keys
      num = parseInt num 
      log 'label: ' + json.data[num]['label']['val']
      log 'data: ' + json.data[num]['data']['val']
      
      data.setValue(6-num, 0, json.data[num]['label']['val'])
      data.setValue(6-num, 1, json.data[num]['data']['val'])
      
    
    chart = new google.visualization.LineChart(document.getElementById('chart-div'))
    chart.draw(data, {width: 400, height: 240, title: 'New user signups in the last week'})
 
     
  getChartData: ->
    Dreamcatcher.Models.Admin.loadChart @getChartOptions('last_7_days_in_users'), @drawChart
        
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
    
  '#chart-test click': (el) ->
    # the google.load command needs to be loaded in resources/google.charts.coffee so that it loads before this controller loads
    # google.setOnLoadCallback @drawChart()
  
    
    