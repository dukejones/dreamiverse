$.Controller 'Dreamcatcher.Controllers.Charts',

  drawLineChart: (json) ->
    data = new google.visualization.DataTable()
  
    numLines = json.data['lines'].length - 1 # account for zero's
    maxRange = parseInt json.data['max_range']  
    range_keys = [0..maxRange] # for date ranges
    line_keys = [0..numLines]  # for data lines

    # Add columns
    data.addColumn('string', 'Date')
    for line in json.data['lines']
      data.addColumn('number', line)
    
    # Add rows
    data.addRows(range_keys.length)
    
    # Add labels & values
    for range_key in range_keys # for each date range    
      for line_key in line_keys # add labels & values for each column/line  
        # setValue paramaters are: range_position, line_num, value)      
        data.setValue(maxRange-range_key, 0, json.data[range_key]['label']) if line_key is 0 
        data.setValue(maxRange-range_key, line_key+1, json.data[range_key]['data']['vals'][line_key])
        
    # Generate chart
    chart = new google.visualization.LineChart(document.getElementById('chart-div'))
    chart.draw(data, {width: 600, height: 240, title: "#{json.data['title']}"})

    log "numLines: #{numLines} maxRange: #{maxRange} line_keys: #{line_keys}"

  drawPieChart: (json) ->
    dataTable = new google.visualization.DataTable()
    dataTable.addRows(4)

    dataTable.addColumn('number')
    dataTable.setValue(0, 0, 32.78688524590164)
    dataTable.setValue(1, 0, 50.81967213114754)
    dataTable.setValue(2, 0, 100)
    dataTable.setValue(3, 0, 42.622950819672134)
    vis = new google.visualization.ImageChart(document.getElementById('chart-div'))
    options = {
      chs: '300x150',
      cht: 'p3',
      chco: '7777CC|76A4FB|3399CC|3366CC',
      chd: 's:Uf9a',
      chdl: 'January|February|March|April',
      chl: '|||'
    }
    vis.draw(dataTable, options)
    

  getLineChartData: (title) ->
    
    Dreamcatcher.Models.Chart.loadLineChart @getChartOptions(title), @drawLineChart  

  getPieChartData: (title) ->
    Dreamcatcher.Models.Chart.loadPieChart @getChartOptions(title), @drawPieChart
    
  # Generate model options   
  getChartOptions: (title) ->
    title: title
     