
$(document).ready ->
  tagsController = new TagsController('.showTags', 'show')
  $('.gallery .lightbox a').lightBox();
  
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
    
  #tags/order_custom = url, with the params: entry_id and position_list (your ordered list of ids) to it?
	 
      
	
	# Setup comment expander
	$('textarea#comment_body').autoResize
	  animationDuration: 500
	  animate: true
	  extraSpace: 40
	  
  # setup links favico
  $('.link a').each ->
    if this.hostname && this.hostname != location.hostname
      $(this).before '<img class="attachedLink" src="http://' + this.hostname + '/favicon.ico" />'
      
      # Check for favico error
      $(".attachedLink").bind "error", ->
        $(this).attr('src', '/images/icons/link-16.gif')

  # setup remove comment handler
  $('.deleteComment').live 'click', (event)->
    tempCount = $('.commentsHeader .counter').html();
    tempCount--
    $('.commentsHeader .counter').html(tempCount)
    $(event.currentTarget).parent().parent().slideUp()
  
    
  # Hide the elements in the browsers they cant be seen in
  if window.BrowserDetect.browser is "Safari" or window.BrowserDetect.browser is "Chrome"
    # for show entry
    $('.tagInput').css('width', '250px')
  
  
  
  
  # Setup youtube links to show thumbnails
  # $('.entryLinks .link').each( (i, val) ->
  #     url = $(this).find('a').attr('href')
  #     domain = url.substring(0, url.indexOf('/', 14))
  #     
  #     if domain is "http://www.youtube.com" or domain is "www.youtube.com"
  #       splitTextArray = url.split('v=');
  #       filePath = 'http://gdata.youtube.com/feeds/api/videos?q=' + splitTextArray[splitTextArray.length - 1] + '&alt=json&max-results=30&format=5';
  #   
  #       # Get the data from YOUTUBE
  #       $.ajax({
  #         url: filePath
  #         dataType: 'jsonp'
  #         success: (data) ->
  #           console.log data
  #           newElement = '<li class="youtube" style="background: url(' + data.feed.entry[0].media$group.media$thumbnail[0].url + ') center center no-repeat;"><img src="/images/icons/youtube-video-112.png"><a target="_blank" href="' + url + '"></a></li>'
  #           #newElement = '<div class="linkContainer"><div class="thumb"><img width="120" height="90" src="' + data.feed.entry[0].media$group.media$thumbnail[0].url + '" /></div><div class="title"><input class="linkTitleValue" value="' + data.feed.entry[0].title.$t + '" name="entry[links_attributes][][title]" /></div><div class="url"><input value="' + newText + '" class="linkTitleValue" name="entry[links_attributes][][url]" style="width: 320px;"></div><div class="removeicon">X</div><div class="icon"><img src="http://www.google.com/s2/favicons?domain_url=' + newText + '" /></div></div>';
  #           $('.content .gallery').append(newElement);
  #       });
  #     
  #   )
# function getBaseURL() {
#     var url = location.href;  // entire url including querystring - also: window.location.href;
#     var baseURL = url.substring(0, url.indexOf('/', 14));
# 
# 
#     if (baseURL.indexOf('http://localhost') != -1) {
#         // Base Url for localhost
#         var url = location.href;  // window.location.href;
#         var pathname = location.pathname;  // window.location.pathname;
#         var index1 = url.indexOf(pathname);
#         var index2 = url.indexOf("/", index1 + 1);
#         var baseLocalUrl = url.substr(0, index2);
# 
#         return baseLocalUrl + "/";
#     }
#     else {
#         // Root Url for domain name
#         return baseURL + "/";
#     }
# 
# }  
  
  
  
    
# There is a point where using objects is just more obfuscation.

# If abstraction doesn't simplify, it's not worth it.
commentsPanel = $('#showEntry .commentsPanel')

$('form#new_comment').bind 'ajax:success', (event, xhr, status)->
  $('textarea', this).val('')
  
  # Update comment count
  newVal = parseInt($('.commentsHeader .counter').text()) + 1
  $('.commentsHeader .counter').text(newVal)
  
  commentsPanel.find('.target').children().last().prev().before(xhr).prev().hide().slideDown()


# TODO
#   # insert the failure message inside the "#account_settings" element
