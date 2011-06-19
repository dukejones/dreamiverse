$.Controller 'Dreamcatcher.Controllers.Admin.Charts', {
  pluginName: 'charts'
}, {

  drawLineChart: (type, json) ->
    data = new google.visualization.DataTable() 
    numLines = json.data['lines'].length - 1 # account for zero's
    maxRange = parseInt json.data['date_max_range']  
    rangeKeys = [0..maxRange] # for date ranges
    lineKeys = [0..numLines]  # for data lines
    chartDivId = "#{type}-chart"
    

    # Add columns
    data.addColumn('string', 'Date')
    for line in json.data['lines']
      data.addColumn('number', line)
    
    # Add rows
    data.addRows(rangeKeys.length)
    
    # Add labels & values
    for range_key in rangeKeys # for each date range    
      for line_key in lineKeys # add labels & values for each column/line  
        # setValue paramaters are: range_position, line_num, value)      
        data.setValue(maxRange-range_key, 0, json.data[range_key]['label']) if line_key is 0 
        data.setValue(maxRange-range_key, line_key+1, json.data[range_key]['vals'][line_key])
        
    # Generate chart
    chart = new google.visualization.LineChart(document.getElementById(chartDivId))
    chart.draw(data, {
      title: "#{json.data['title']}",
      width: 600, height: 300, 
      backgroundColor: 'black',
      legendTextStyle: {color: 'white'},
      titleTextStyle: {cƒolor: 'white'},
      hAxis: {textStyle: {color: 'white'}},
      vAxis: {textStyle: {color: 'white'}}
    })
      
    $("##{type}-chartLoading").hide()

  drawPieChart: (type, json) ->
    data = new google.visualization.DataTable()   
    numSlices = json.data['slices'].length - 1 # account for zero's
    sliceKeys = [0..numSlices]  
    chartDivId = "#{type}-chart"
    
    # Add columns
    data.addColumn('string', 'seed code')
    data.addColumn('number', 'value')
    
    # Add rows
    data.addRows(sliceKeys.length)
    
    # Add labels & values 
    for key in sliceKeys 
      data.setValue(key, 0, json.data[key]['label'])
      data.setValue(key, 1, json.data[key]['val'])
     
    # Generate Chart
    chart = new google.visualization.PieChart(document.getElementById(chartDivId))
    chart.draw(data, {
      title: "#{json.data.title}"
      width: 600
      height: 300
      cht: 'p3'
      is3D: true
      backgroundColor: 'black'
      legendTextStyle: {color: 'white'}
      titleTextStyle: {color: 'white'}
    })

    $("##{type}-chartLoading").hide() 
      
  getLineChartData: (title,type) ->  
    $("##{type}-chartLoading").show()           
    Dreamcatcher.Models.Chart.loadSimpleLineChart @getChartOptions(title), @callback('drawLineChart',type) 
    

  getPieChartData: (title,type) ->
    $("##{type}-chartLoading").show() 
    Dreamcatcher.Models.Chart.loadPieChart @getChartOptions(title), @callback('drawPieChart',type)
    
  getChartOptions: (title) ->
    title: title
     
}