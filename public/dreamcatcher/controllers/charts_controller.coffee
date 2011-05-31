$.Controller 'Dreamcatcher.Controllers.Charts',
  
  init: ->
    # dlog 'running charts controllers scope: ' + scope
    @scope = 'test'
    
  drawLineChart: (json) ->

    data = new google.visualization.DataTable()
    data.addColumn('string', 'Date')
    data.addColumn('number', 'New Users')
    data.addColumn('number', 'New Users2')
    
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
    data = new google.visualization.DataTable()
    
    # Add columns
    data.addColumn('string', 'Date')
    for column in json.data['columns']
      data.addColumn('number', column)
  
    numCols = parseInt json.data['num_cols']
    maxRange = parseInt json.data['max_range']  
    ranges = [0..maxRange]
    cols = [0..numCols]
   
    log "numCols: #{numCols} maxRange: #{maxRange} cols: #{cols}"

    data.addRows(ranges.length)
     
    for range in ranges # for each date range    
      for col in cols # add label + values for each column         
        data.setValue(maxRange-range, 0, json.data[range]['label']) if col is 0 
        data.setValue(maxRange-range, col+1, json.data[range]['data']['vals'][col])

    chart = new google.visualization.LineChart(document.getElementById('chart-div'))
    chart.draw(data, {width: 600, height: 240, title: "test #{@scope}"})


  getChartData: (scope) ->
    @scope = scope
    log 'running getChartData ' + @scope
    # Dreamcatcher.Models.Admin.loadChart @getChartOptions(scope), @drawLineChart  
    if scope is 'last_6_months_in_entry_types' # or if scope is 'last_6_months_in_entries' 
      Dreamcatcher.Models.Admin.loadChart @getChartOptions(scope), @drawMultiLineChart
    else 
      Dreamcatcher.Models.Admin.loadChart @getChartOptions(scope), @drawLineChart

    
  # Generate model options   
  getChartOptions: (scope) ->
    scope: scope
     