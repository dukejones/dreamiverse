$.Controller 'Dreamcatcher.Controllers.Charts',
  
  init: ->
    log 'running charts controllers'
    @scope = 'none'
    
  drawLineChart: (json) =>
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
    chart.draw(data, {width: 400, height: 240, title: "test #{@scope}"})


  getChartData: (scope) ->
    @scope = scope
    log 'running getChartData ' + @scope
    Dreamcatcher.Models.Admin.loadChart @getChartOptions(), @drawLineChart
    
  # Generate model options   
  getChartOptions: ->
    scope: @scope
     