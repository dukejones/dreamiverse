$.Controller 'Dreamcatcher.Controllers.Admin',
  
  init: -> 
    @page = 1   
    @totalUsers = parseInt $('#totalUsers').data 'id'
    @pageSize = $('#pageSize').data 'id'
    @totalPages = Math.ceil(@totalUsers / @pageSize)    
    @addPageLinks()
    @updateNav()
        
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

  drawChart: ->
    data = new google.visualization.DataTable()
    data.addColumn('string', 'Year')
    data.addColumn('number', 'Sales')
    data.addColumn('number', 'Expenses')
    data.addRows(4)
    data.setValue(0, 0, '2004')
    data.setValue(0, 1, 1000)
    data.setValue(0, 2, 400)
    data.setValue(1, 0, '2005')
    data.setValue(1, 1, 1170)
    data.setValue(1, 2, 460)
    data.setValue(2, 0, '2006')
    data.setValue(2, 1, 860)
    data.setValue(2, 2, 580)
    data.setValue(3, 0, '2007')
    data.setValue(3, 1, 1030)
    data.setValue(3, 2, 1540)

    chart = new google.visualization.LineChart(document.getElementById('chart-div'))
    chart.draw(data, {width: 400, height: 240, title: 'Company Performance'})
      
        
  # Dom listeners
  '.userPage click': (el,ev) ->
    @page = parseInt el.text()
    $('#allUsersIcon').hide()
    $('#pageLoading').show()
    Dreamcatcher.Models.Admin.load @getOptions(), @updateUsersPage
    @updateNav()     

  '#nextPage, #prevPage click': (el,ev) ->
    @page = 1 if !@page? 
    @page = if ev.currentTarget.id is 'nextPage' then @page += 1 else @page -= 1 
    $('#allUsersIcon').hide()
    $('#pageLoading').show()
    Dreamcatcher.Models.Admin.load @getOptions(), @updateUsersPage  
    @updateNav() 
    
  '#user-filter change': (el) ->
    log 'user-filter changed to: ' + el.val()
    @page = 1 
    $('#pageLoading').show()
    Dreamcatcher.Models.Admin.load @getOptions(), @updateUsersPage  
    @updateNav()    
    
  '#chart-test click': (el) ->
    # the google.load command needs to be loaded in resources/google.charts.coffee so that it loads before this controller loads
    google.setOnLoadCallback @drawChart()
  
    
    