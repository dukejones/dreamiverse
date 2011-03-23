getYoutubeData = (video_url, linked_element) ->
  splitTextArray = video_url.split('v=');
  filePath = 'http://gdata.youtube.com/feeds/api/videos?q=' + splitTextArray[splitTextArray.length - 1] + '&alt=json&max-results=30&format=5';
  
  # Get the data from YOUTUBE
  $.ajax({
    url: filePath
    dataType: 'jsonp'
    success: (data) ->
      ua = navigator.userAgent
      if ua.match(/iPad/i)
        # IPAD Server HTML5 player
        videoArray = data.feed.entry[0].id.$t.split('/')
        video_id = videoArray[videoArray.length - 1]
        embedPlayer = '<iframe class="youtube-player" type="text/html" width="622" height="390" src="http://www.youtube.com/embed/' + video_id + '" frameborder="0"></iframe>'
      else
        # Normal flash w/ autoplay
        videoPath = data.feed.entry[0].media$group.media$content[0].url;
        embedPlayer = '<object width="614" height="390"><param name="movie" value="' + videoPath + '&autoplay=1&hd=1"></param><param name="wmode" value="transparent"></param><embed src="' + videoPath + '&autoplay=1&hd=1" type="application/x-shockwave-flash" wmode="transparent" width="614" height="390"></embed></object>';

      #embedPlayer = '<object width="614" height="390"><param name="movie" value="' + videoPath + '"></param><param name="wmode" value="transparent"></param><embed src="' + videoPath + '" type="application/x-shockwave-flash" wmode="transparent" width="614" height="390"></embed></object>'
      #embedPlayer = '<iframe class="youtube-player" type="text/html" width="614" height="390" src="http://www.youtube.com/embed/' + video_id + '" frameborder="0"></iframe>'
      thumbnail_url = data.feed.entry[0].media$group.media$thumbnail[0].url
      
      #var newElement = '<div class="linkContainer youtube"><div class="title"><input class="linkTitleValue" style="width: 220px;" value="' + data.feed.entry[0].title.$t + '" name="entry[links_attributes][][title]" /></div><div class="url"><input value="' + newText + '" class="linkUrlValue" name="entry[links_attributes][][url]" style="width: 320px;"><div class="icon"><img src="http://www.google.com/s2/favicons?domain_url=' + newText + '" /></div></div><div class="removeicon"></div><div class="thumb" style="background: url(' + data.feed.entry[0].media$group.media$thumbnail[1].url + ') no-repeat center center transparent"></div><div class="description">' + data.feed.entry[0].content.$t + '</div></div>'
      $.publish 'youtube:data', [linked_element, thumbnail_url, embedPlayer]
  })
#Working on coffeescripting out the linkifyer
# linkify = (text) ->
#   if !text
#     return text;
#     
#   text = text.replace(/((https?\:\/\/|ftp\:\/\/)|(www\.))(\S+)(\w{2,4})(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/gi, (url) ->
#     nice = url;
#     if url.match('^https?:\/\/')
#       nice = nice.replace(/^https?:\/\//i,'')
#     else
#       url = 'http://'+url
#       
#     return '<a target="_blank" rel="nofollow" href="'+ url +'">'+ nice.replace(/^www./i,'') +'</a>';
#   
#   return text;
  
$(document).ready ->
  tagsController = new TagsController('.showTags', 'show')
  $('.gallery .lightbox a').lightBox({containerResizeSpeed: 0})
  
  $('#comment_submit').hide()
  $('#comment_body').live "focus", ->
    $('#comment_submit').fadeIn(250)
  
  $('#comment_body').keyup ->
    fitToContent(this, 0)
  
  # Setup sharing level icon change
  $('.shareLevel').find('span').each( (i, el)->
    switch $(this).text()
      when 'private'
        $(this).prev().css('background', 'url(/images/icons/private-16.png) no-repeat center')
      when 'anonymous'
        $(this).prev().css('background', 'url(/images/icons/anon-16.png) no-repeat center')
      when 'users'
        $(this).prev().css('background', 'url(/images/icons/listofUsers-16.png) no-repeat center')
      when 'followers'
        $(this).prev().css('background', 'url(/images/icons/friend-follower-16.png) no-repeat center')
      when 'friends'
        $(this).prev().css('background', 'url(/images/icons/friend-none-16.png) no-repeat center')
      when 'friends of friends'
        $(this).prev().css('background', 'url(/images/icons/friend-none-16.png) no-repeat center')
      when 'everyone'
        $(this).prev().css('background', 'url(/images/icons/sharing-16.png) no-repeat center')
  )
  
  $('.gallery .youtube').each (i, el) =>
    # Pass the url and the element it came from
    getYoutubeData($(el).find('a').attr('href'), $(el))
    
    # Setup video expander
    link_id = $(el).data('id')
    # make iPad 1 click work on thumbs
    ua = navigator.userAgent
    clickEvent = if (ua.match(/iPad/i)) then "touchstart" else "click"

    $(el).find('a').bind(clickEvent, (event) =>
      event.preventDefault()
      
      $('.video').hide()
      $('.gallery .youtube').show()
      
      # remove li
      $(event.currentTarget).parent().hide()
      
      new_id = $(event.currentTarget).parent().data('id')
      $container = $("#" + new_id).parent().parent()
      $container.find('.minimize').click( (event) =>
        $('.video').hide()
        $('.gallery .youtube').show()
      )
      $container.show()
    )
  
  commentsPanel = $('#showEntry .commentsPanel')

  # $('form#new_comment').bind 'ajax:success', (event, xhr, status)->
  #   $('textarea', this).val('')
  #   console.log('COMMENT SUCCESS')
  # 
  #   # Update comment count
  #   newVal = parseInt($('.commentsHeader .counter').text()) + 1
  #   $('.commentsHeader .counter').text(newVal)
  # 
  #   commentsPanel.find('.target').children().last().prev().before(xhr).prev().hide().slideDown()
  
  $.subscribe 'youtube:data', ($element, thumbnail, videoEmbed)=> 
    # Set BG Image
    $element.css('background-image', 'url(' + thumbnail + ')')
    $element.css('background-position', 'center center')
    
    # Drop in video embed
    link_id = $element.data('id')
    $('#' + link_id).data({'id': "videoEmbed"})
    $('#' + link_id).append(videoEmbed)
  
  ### disabled until update entry ordering is working again
  # Setup tag re-ordering
  if $('#entryField').data('owner')
    $("#sorting").val(1)
    $("#tag-list").sortable -> distance: 30
  
  	$( "#tag-list" ).bind "sortstart", (event, ui) ->
  	  $("#sorting").val(0)
	  
  	$( "#tag-list" ).bind "sortstop", (event, ui) ->
  	  $("#sorting").val(1)
	  
  	  tagOrder = []
  	  $('#tag-list > .tag').each (i, el) ->
  	    tagOrder.push($(this).data('id'))
	    
  	  entry = $('#showEntry').data('id')
  	  order = tagOrder.join()
	  
  	  $.ajax {
        type: 'PUT'
        url: '/tags/order_custom'
        data:
          entry_id: entry
          position_list: order
        #success: (data, status, xhr) => log "success"
      }
  ### 
  
  #tags/order_custom = url, with the params: entry_id and position_list (your ordered list of ids) to it?

  $('#comment_body').css('overflow','hidden')
	  
  # setup remove comment handler
  $('.deleteComment').live 'click', (event)->
    tempCount = $('.commentsHeader .counter').html();
    tempCount--
    $('.commentsHeader .counter').html(tempCount)
    $(event.currentTarget).parent().parent().slideUp(250)
  
    
  # Hide the elements in the browsers they cant be seen in
  if window.BrowserDetect.browser is "Safari" or window.BrowserDetect.browser is "Chrome"
    # for show entry
    $('.tagInput').css('width', '250px') 
  
  
  
  # Setup youtube attachments to load in on the page & links favico
  $('.link a').each ->
    if this.hostname && this.hostname != location.hostname
      $(this).before '<img class="attachedLink" src="http://' + this.hostname + '/favicon.ico" />'
      
      # Check for favico error
      $(".attachedLink").bind "error", ->
        $(this).attr('src', '/images/icons/link-16.png')


# TODO
#   # insert the failure message inside the "#account_settings" element
