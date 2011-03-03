getYoutubeData = (video_url, linked_element) ->
  splitTextArray = video_url.split('v=');
  filePath = 'http://gdata.youtube.com/feeds/api/videos?q=' + splitTextArray[splitTextArray.length - 1] + '&alt=json&max-results=30&format=5';
  
  # Get the data from YOUTUBE
  $.ajax({
    url: filePath
    dataType: 'jsonp'
    success: (data) ->
      videoPath = data.feed.entry[0].media$group.media$content[0].url
      embedPlayer = '<object width="622" height="390"><param name="movie" value="' + videoPath + '"></param><param name="wmode" value="transparent"></param><embed src="' + videoPath + '" type="application/x-shockwave-flash" wmode="transparent" width="622" height="390"></embed></object>'
      
      thumbnail_url = data.feed.entry[0].media$group.media$thumbnail[1].url
      
      #var newElement = '<div class="linkContainer youtube"><div class="title"><input class="linkTitleValue" style="width: 220px;" value="' + data.feed.entry[0].title.$t + '" name="entry[links_attributes][][title]" /></div><div class="url"><input value="' + newText + '" class="linkUrlValue" name="entry[links_attributes][][url]" style="width: 320px;"><div class="icon"><img src="http://www.google.com/s2/favicons?domain_url=' + newText + '" /></div></div><div class="removeicon"></div><div class="thumb" style="background: url(' + data.feed.entry[0].media$group.media$thumbnail[1].url + ') no-repeat center center transparent"></div><div class="description">' + data.feed.entry[0].content.$t + '</div></div>'
      $.publish 'youtube:data', [linked_element, thumbnail_url, embedPlayer]
  })


streamController = null

$(document).ready ->
  streamController = new StreamController()
  
  # loop thru the youtube attachments
  $('.entryImages .youtube').each (i, el) =>
    # Pass the url and the element it came from
    getYoutubeData($(el).find('a').attr('href'), $(el))
    
    # Setup video expander
    link_id = $(el).data('id')
    $(el).find('a').click( (event) =>
      event.preventDefault()
      $('.youtubeEmbed').slideUp('300', ->
        $("#" + new_id).show()
      )
      $(event.currentTarget).parent().parent().parent().parent().parent().parent().parent().addClass('videoExpand')
      
      
      new_id = $(event.currentTarget).parent().data('id')
      $container = $("#" + new_id).parent().parent()
      if $container.css('display') == 'none'
        $container.show()
      
      $("#" + new_id).show()
    )
  
  $.subscribe 'youtube:data', ($element, thumbnail, videoEmbed)=> 
    # Set BG Image
    $element.css('background-image', 'url(' + thumbnail + ')')
    $element.css('background-position', 'center center')
    
    # Drop in video embed
    link_id = $element.data('id')
    $('#' + link_id).append(videoEmbed)

class StreamController
  constructor: ->
    # listen for filter:change update
    $.subscribe 'filter:change', => @streamModel.updateFilters()
    
    $.subscribe 'stream:update', (elements) => @streamView.update(elements)
    
    @streamModel = new StreamModel()
    @streamView = new StreamView()
    
    # Setup youtube images for each entry
    
    # Setup lightbox for stream
    $('a.lightbox').lightBox({containerResizeSpeed: 100});
    



class StreamView
  constructor: () ->
    @$container = $('#entryField .matrix')
    
  update: (elements) ->
    @$container.html(elements)



class StreamModel
  updateData: ->
    $.getJSON("/stream.json", {
      filters:
        type: @filters[0]
        friend: @filters[1]
        starlight: @filters[2]
    },
    (data) =>
      log data
    )
    
  updateFilters: () ->
    @filters = []
    # get new filter values (will be .filter .value to target the span)
    $.each $('.trigger .value'), (key, value) =>
      @filters.push($(value).text())
    @updateData()