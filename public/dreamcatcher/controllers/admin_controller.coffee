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


  drawChart: (json) ->
    log json.data
    log json.data[0]['label']['val']
    # log json['total']
    data = new google.visualization.DataTable()
    data.addColumn('string', 'Date')
    data.addColumn('number', 'New Users')
    data.addRows(7)    
    fehz = for num of json.data
      num = parseInt num
      log num
      data.setValue(num, num, json.data[num]['label']['val'])
      data.setValue(num, (num + 1), json.data[num]['data']['val'])
    
    data.setValue(0, 0, '2004')
    data.setValue(0, 1, 1000)
    data.setValue(1, 0, '2005')
    data.setValue(1, 1, 1170)
    data.setValue(2, 0, '2006')
    data.setValue(2, 1, 860)
    data.setValue(3, 0, '2007')
    data.setValue(3, 1, 1030)
    # (0..6).each do |num| 
    #   day = (Time.now - num.days)
    #   data.setValue(num, 0, t.strftime("%d"))
    #   data.setValue(num, 1, num)
    # end
    chart = new google.visualization.LineChart(document.getElementById('chart-div'))
    chart.draw(data, {width: 400, height: 240, title: 'Company Performance'})
     
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
  
    
    