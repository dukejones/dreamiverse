$.Controller 'Dreamcatcher.Controllers.Charts',

  drawLineChart: (json) ->
    data = new google.visualization.DataTable() 
    numLines = json.data['lines'].length - 1 # account for zero's
    maxRange = parseInt json.data['date_max_range']  
    rangeKeys = [0..maxRange] # for date ranges
    lineKeys = [0..numLines]  # for data lines

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
    chart = new google.visualization.LineChart(document.getElementById('chart-div'))
    chart.draw(data, {
      title: "#{json.data['title']}",
      width: 600, height: 300, 
      backgroundColor: 'black',
      legendTextStyle: {color: 'white'},
      titleTextStyle: {color: 'white'},
      hAxis: {textStyle: {color: 'white'}},
      vAxis: {textStyle: {color: 'white'}}
    })


  drawSparklineChart: (json) ->
    data = new google.visualization.DataTable() 
    numLines = json.data['lines'].length - 1 # account for zero's
    maxRange = parseInt json.data['date_max_range']  
    rangeKeys = [0..maxRange] # for date ranges
    lineKeys = [0..numLines]  # for data lines


    
    data.addRows(maxRange + 1)
    
    # Add labels & values
    for day in [0..1]

       
      for hour in [0..23] # for each date range  
           
        # setValue paramaters are: range_position, line_num, value)  
        data.addColumn('number','test')
        data.addColumn('number','entries per hour')     
        data.setValue(maxRange-hour, 0, day) # if range_key is 0   
        data.setValue(maxRange-hour, 1, json.data[hour]['vals'][0])
      
    #     
    # data.addRows(100);
    # data.setValue(0,0,435);
    # data.setValue(1,0,438);
    # data.setValue(2,0,512);
    # data.setValue(3,0,460);
    # data.setValue(4,0,491);
    # data.setValue(5,0,487);
    # data.setValue(6,0,552);
    # data.setValue(7,0,511);
    # data.setValue(8,0,505);
    # data.setValue(9,0,509);

    
    chart = new google.visualization.ImageSparkLine(document.getElementById('chart-div'));
    chart.draw(data, {width: 600, height: 200, titleTextStyle: {color: 'black'}, fill: true, showAxisLines: true,  showValueLabels: true, labelPosition: 'left', axisRanges: 0,0,500,1,0,200,2,1000,0});
      
          

  drawPieChart: (json) ->
    data = new google.visualization.DataTable()   
    numSlices = json.data['slices'].length - 1 # account for zero's
    sliceKeys = [0..numSlices]  
    
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
    chart = new google.visualization.PieChart(document.getElementById('chart-div'))
    chart.draw(data, {
      title: "#{json.data.title}"
      width: 600
      height: 300
      cht: 'p3'
      is3D: true
      backgroundColor: 'black'
      legendTextStyle: {color: 'white'}
      titleTextStyle: {color: 'white'}})

     
  getLineChartData: (title) ->               
    Dreamcatcher.Models.Chart.loadSimpleLineChart @getChartOptions(title), @drawLineChart  

  getSparklineChartData: (title) ->               
    Dreamcatcher.Models.Chart.loadFancyLineChart @getChartOptions(title), @drawSparklineChart
      
  getPieChartData: (title) ->
    Dreamcatcher.Models.Chart.loadPieChart @getChartOptions(title), @drawPieChart
    
  # Generate model options   
  getChartOptions: (title) ->
    title: title
     