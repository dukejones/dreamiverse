getYoutubeData = (video_url, linked_element) ->
  splitTextArray = video_url.split('v=');
  filePath = 'http://gdata.youtube.com/feeds/api/videos?q=' + splitTextArray[splitTextArray.length - 1] + '&alt=json&max-results=30&format=5';
  
  # Get the data from YOUTUBE
  $.ajax({
    url: filePath
    dataType: 'jsonp'
    success: (data) ->
      videoArray = data.feed.entry[0].id.$t.split('/')
      video_id = videoArray[videoArray.length - 1]
      embedPlayer = '<iframe class="youtube-player" type="text/html" width="622" height="390" src="http://www.youtube.com/embed/' + video_id + '" frameborder="0"></iframe>'
      
      videoPath = data.feed.entry[0].media$group.media$content[0].url
      #embedPlayer = '<object width="622" height="390"><param name="movie" value="' + videoPath + '"></param><param name="wmode" value="transparent"></param><embed src="' + videoPath + '" type="application/x-shockwave-flash" wmode="transparent" width="622" height="390"></embed></object>'
      
      thumbnail_url = data.feed.entry[0].media$group.media$thumbnail[1].url
      
      #var newElement = '<div class="linkContainer youtube"><div class="title"><input class="linkTitleValue" style="width: 220px;" value="' + data.feed.entry[0].title.$t + '" name="entry[links_attributes][][title]" /></div><div class="url"><input value="' + newText + '" class="linkUrlValue" name="entry[links_attributes][][url]" style="width: 320px;"><div class="icon"><img src="http://www.google.com/s2/favicons?domain_url=' + newText + '" /></div></div><div class="removeicon"></div><div class="thumb" style="background: url(' + data.feed.entry[0].media$group.media$thumbnail[1].url + ') no-repeat center center transparent"></div><div class="description">' + data.feed.entry[0].content.$t + '</div></div>'
      $.publish 'youtube:data', [linked_element, thumbnail_url, embedPlayer]
  })

$(document).ready ->
  
  # loop thru the youtube attachments
  $('.entryImages .youtube').each (i, el) =>
    # Pass the url and the element it came from
    getYoutubeData($(el).find('a').attr('href'), $(el))
    
    # Setup video expander
    link_id = $(el).data('id')
    $(el).find('a').click( (event) =>
      event.preventDefault()
      
      $('.thumb-1d .video').hide()
      $('.thumb-1d').removeClass('videoExpand')
      
      #$('.video').hide()
      $parent = $(event.currentTarget).parent().parent().parent().parent().parent().parent().parent()
      $parent.addClass('videoExpand')
      
      new_id = $(event.currentTarget).parent().data('id')
      $container = $("#" + new_id).parent().parent()
      $container.show()
    )
  
  $.subscribe 'youtube:data', ($element, thumbnail, videoEmbed)=> 
    # Set BG Image
    $element.css('background-image', 'url(' + thumbnail + ')')
    $element.css('background-position', 'center center')
    
    # Drop in video embed
    link_id = $element.data('id')
    $('#' + link_id).append(videoEmbed)