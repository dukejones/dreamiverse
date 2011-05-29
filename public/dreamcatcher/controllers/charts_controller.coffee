$.Controller 'Dreamcatcher.Controllers.Charts',
  
  init: ->
    # dlog 'running charts controllers scope: ' + scope
    @scope = 'test'
    
  drawLineChart: (json) ->
    log json.data
    log json.data[0]['label']['val']

    data = new google.visualization.DataTable()
    data.addColumn('string', 'Date')
    data.addColumn('number', 'New Users')

    numKeys = parseInt json.data['total']
    log 'numKeys: ' + numKeys

    keys = [numKeys..0]
    data.addRows(keys.length) 
    for num in keys
      num = parseInt num 
      # log 'label: ' + json.data[num]['label']['val']
      # log 'data: ' + json.data[num]['data']['val']

      data.setValue(numKeys-num, 0, json.data[num]['label']['val'])
      data.setValue(numKeys-num, 1, json.data[num]['data']['val'])


    chart = new google.visualization.LineChart(document.getElementById('chart-div'))
    chart.draw(data, {width: 600, height: 240, title: "test #{@scope}"})

  drawMultiLineChart: (json) ->
    log 'test'
    data = new google.visualization.DataTable();
    data.addColumn('string', 'date');
    data.addColumn('number', 'dream');
    data.addColumn('number', 'vision');
    data.addColumn('number', 'experience');
    data.addColumn('number', 'article');
    data.addColumn('number', 'journal');
    numKeys = parseInt json.data['total']
    log 'numKeys: ' + numKeys

    keys = [numKeys..0]
    data.addRows(keys.length) 
    for num in keys
      num = parseInt num 
      log 'label: ' + json.data[num]['label']['val']
      log 'data: ' + json.data[num]['data']['val1']

      data.setValue(numKeys-num, 0, json.data[num]['label']['val'])
      data.setValue(numKeys-num, 1, json.data[num]['data']['val1'])    
      data.setValue(numKeys-num, 2, json.data[num]['data']['val2']) 
      data.setValue(numKeys-num, 3, json.data[num]['data']['val3']) 
      data.setValue(numKeys-num, 4, json.data[num]['data']['val4']) 
      data.setValue(numKeys-num, 5, json.data[num]['data']['val5'])
      
    chart = new google.visualization.LineChart(document.getElementById('chart-div'));
    chart.draw(data, {width: 500, height: 400, title: 'Entry types added'});
      
    # new google.visualization.LineChart(document.getElementById('chart-div')).draw(data, null)
    # chart.draw(data, {width: 500, height: 400, title: "test #{@scope}"})



  getChartData: (scope) ->
    @scope = scope
    log 'running getChartData ' + @scope
    # Dreamcatcher.Models.Admin.loadChart @getChartOptions(scope), @drawLineChart
    if scope is 'last_6_months_in_entry_types' 
      Dreamcatcher.Models.Admin.loadChart @getChartOptions(scope), @drawMultiLineChart
    else 
      Dreamcatcher.Models.Admin.loadChart @getChartOptions(scope), @drawLineChart

    
  # Generate model options   
  getChartOptions: (scope) ->
    scope: scope
     