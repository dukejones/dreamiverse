/* TO DO: refactor and merge with entry body links */
/* inside dreams.js */

jQuery.fn.videolink = function(){
  $('.body a',this).each(function(i, ele){
    var current_url = $(ele).attr('href');
    var $current_element = $(ele);
    var tempAnchor = $("<a />");
    tempAnchor.attr('href', current_url)
    var hostname = tempAnchor.attr('hostname');

    // This checks if a youtube link is attached that IS NOT a video
    // Makes it pass as a normal link
    if((current_url.indexOf("v=") == -1) && (hostname.indexOf("youtube.com") != -1)){
      hostname = "dreamcatcher.net";
    }



    // Checks for SOUNDCLOUD LINK
    if(hostname == "soundcloud.com" || hostname == "www.soundcloud.com"){
      index = $("a.soundcloud").length
      var dataId = String("soundcloud-" + index);
      $(ele).data('id', index);
      $(ele).addClass('soundcloud');

      var filePath = 'http://api.embed.ly/1/oembed?url=' + current_url + '&format=json'
      $.ajax({
        url: filePath,
        dataType: 'jsonp',
        success: function(data) {
          var newElement = '<div class="audio hidden" id="' + dataId + '"> ' + data.html + '</div>';
          $current_element.after(newElement)
          $current_element.next().find('object').attr('width', '100%')
          $current_element.next().find('object').find('embed').attr('width', '100%')
        }
      });

    } else if(hostname == "vimeo.com" || hostname == "www.vimeo.com"){
      index = $("a.vimeo").length
      var dataId = String("vimeo-" + index);
      $(ele).data('id', index);
      $(ele).addClass('vimeo');

      var filePath = 'http://api.embed.ly/1/oembed?url=' + current_url + '&format=json'
      $.ajax({
        url: filePath,
        dataType: 'jsonp',
        success: function(data) {
          log(data)
          var embedPlayer = data.html;
          var newElement = '<div class="video hidden" id="' + dataId + '"><div class="close-24 minimize hidden"></div><div class="player">' + embedPlayer + '</div><div class="info"><div style="background: url(/assets/icons/vimeo-24.png) no-repeat center" class="logo"></div><span class="videoTitle">' + data.title + '</span></div></div>';
          $current_element.after(newElement)
          $current_element.next().find('iframe').attr('width', '472')
          $current_element.next().find('iframe').attr('height', '390')
        }
      });

    } else if(hostname == "youtube.com" || hostname == "www.youtube.com"){
      // Create new Element & make it work
      index = $("a.youtube").length
      var dataId = String("youtube-" + index);
      $(ele).data('id', index);

      $(ele).addClass('youtube');

      // Get & set youtube data
      var splitTextArray = String($(ele).attr('href')).split('v=');
      var filePath = 'http://gdata.youtube.com/feeds/api/videos?q=' + splitTextArray[splitTextArray.length - 1] + '&alt=json&max-results=30&format=5';

      // Get the data from YOUTUBE
      $.ajax({
        url: filePath,
        dataType: 'jsonp',
        success: function(data) {
          // Check for non embedable media
          if(typeof data.feed.entry != 'undefined' && data.feed.entry != null){
            var ua = navigator.userAgent
            if(ua.match(/iPad/i)){
              // IPAD Server HTML5 player
              var videoArray = data.feed.entry[0].id.$t.split('/')
              var video_id = videoArray[videoArray.length - 1]
              var embedPlayer = '<iframe class="youtube-player" type="text/html" width="472" height="390" src="http://www.youtube.com/embed/' + video_id + '" frameborder="0"></iframe>'
            } else {
              // Normal flash w/ autoplay
              var videoPath = data.feed.entry[0].media$group.media$content[0].url;
              var embedPlayer = '<object width="472" height="390"><param name="movie" value="' + videoPath + '&autoplay=1&hd=1"></param><param name="wmode" value="transparent"></param><embed src="' + videoPath + '&autoplay=1&hd=1" type="application/x-shockwave-flash" wmode="transparent" width="472" height="390"></embed></object>';
            }

            var newElement = '<div class="video hidden" id="' + dataId + '"><div class="close-24 minimize hidden"></div><div class="player">' + embedPlayer + '</div><div class="info"><div style="background: url(/assets/icons/youtube-24.png) no-repeat center" class="logo"></div><span class="videoTitle">' + data.feed.entry[0].title.$t + '</span></div></div>';
            $current_element.after(newElement)
          } else {
            // Non embedable video
            // Make link work
            $current_element.click(function(){
              window.open(current_url)
            })
          }
        }
      });
    }
  })

  //Copied from dreams.js - duplicate code TODO


  // Add youtube icon after each youtube, soundcloud & vimeo link
  $('a.youtube, a.soundcloud, a.vimeo',this).filter(function(){
    return this.hostname && this.hostname !== location.hostname;
  }).prepend('<div class="img"></div>')

  // WILL NEED TO FIGURE OUT A WAY TO COMBINE ALL OF THESE
  // AND MAKE THEM WORK EASILY W ALL NEW EMBED TYPES!

  // Set click event for youtube links
  $('a.youtube,a.soundcloud,a.vimeo',this).click(function(event){
    event.preventDefault()
    var embedVideo = String("#"+$(this).attr("class")+"-" + $(event.currentTarget).data('id'));
    $(embedVideo).show()
  })
}
