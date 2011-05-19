$(document).ready(function() {
  checkForLinksShowEntry();
  
  setupEvents();
  setupImagebank();
  setupUploader();
  setupLinkButtons();
  setup2dThumbIPadClick();
});

function checkForLinksShowEntry(){
  // Check entry for links and convert to hyperlinks
  var oldCode = $('.content .body').html();
  var newCode = linkify(oldCode);
  $('.content .body').html(newCode);
  
  var oldComments = $('.commentsPanel').html()
  var newComments = linkify(oldComments);
  $('.commentsPanel').html(newComments);
  
  
  embedYoutubeLinks();
}

// Turns all links in the body of an entry
// into embedded youtube links
function embedYoutubeLinks(){
  
  // THIS HAS TWO MAIN FUNCTIONS, ONE GETS EVERYTHING IN THE COMMENTS PANEL
  // ONE GETS ALL OF THE BODY LINKS. WE MAY BE ABLE TO CLEAN THIS UP TO BE ONE
  // NEED TO THINK ABOUT IT FOR A BIT
  
  
  // One for Comments
  // moved to commentLinks.js (for use in new JMVC controllers)
  
  
  
  
  
  
  // One for content body
  $('.content .body').find('a').each(function(i, ele){
    
    var current_url = $(ele).attr('href');
    var $current_element = $(ele);
    var tempAnchor = $("<a />");
    tempAnchor.attr('href', current_url)
    var hostname = tempAnchor.attr('hostname');
    
    // Check to be sure that youtube or soundcloud (or any future embeds) do not
    // appear in the hostname, so it can skip all of this
    if((current_url.indexOf("v=") == -1) && (hostname.indexOf("youtube.com") != -1)){
      hostname = "dreamcatcher.net";
    }
    if(hostname == "soundcloud.com" || hostname == "www.soundcloud.com"){
      // If soundcloud, embed element
      var dataId = String("soundcloud-" + i);
        $(ele).data('id', i);
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
      //http://api.embed.ly/1/oembed?url=http%3A%2F%2Fvimeo.com%2F6775209&maxwidth=600&format=xml
      var dataId = String("vimeo-" + i);
      $(ele).data('id', i);
      $(ele).addClass('vimeo');
      
      var filePath = 'http://api.embed.ly/1/oembed?url=' + current_url + '&format=json'
      $.ajax({
        url: filePath,
        dataType: 'jsonp',
        success: function(data) {
          log(data)
          var embedPlayer = data.html;
          var newElement = '<div class="video hidden" id="' + dataId + '"><div class="close minimize hidden"></div><div class="player">' + embedPlayer + '</div><div class="info"><div style="background: url(/images/icons/vimeo-24.png) no-repeat center" class="logo"></div><span class="videoTitle">' + data.title + '</span></div></div>';
          $current_element.after(newElement)
          $current_element.next().find('iframe').attr('width', '546')
          $current_element.next().find('iframe').attr('height', '390')
        }
      });
         
    
    } else if(hostname == "youtube.com" || hostname == "www.youtube.com"){
      // Create new Youtube Element & make it work
      var dataId = String("youtube-" + i);
      $(ele).data('id', i);
      
      $(ele).addClass('youtube');
      
      // Get & set youtube data
      var splitTextArray = String($(ele).attr('href')).split('v=');
      var filePath = 'http://gdata.youtube.com/feeds/api/videos?q=' + splitTextArray[splitTextArray.length - 1] + '&alt=json&max-results=30&format=5';

      // Get the data from YOUTUBE
      $.ajax({
        url: filePath,
        dataType: 'jsonp',
        success: function(data) {
          if(typeof data.feed.entry != 'undefined' && data.feed.entry != null){
            var ua = navigator.userAgent
            if(ua.match(/iPad/i)){
              // IPAD Server HTML5 player
              var videoArray = data.feed.entry[0].id.$t.split('/')
              var video_id = videoArray[videoArray.length - 1]
              var embedPlayer = '<iframe class="youtube-player" type="text/html" width="546" height="390" src="http://www.youtube.com/embed/' + video_id + '" frameborder="0"></iframe>'
            } else {
              // Normal flash w/ autoplay
              var videoPath = data.feed.entry[0].media$group.media$content[0].url;
              var embedPlayer = '<object width="546" height="390"><param name="movie" value="' + videoPath + '&autoplay=1&hd=1"></param><param name="wmode" value="transparent"></param><embed src="' + videoPath + '&autoplay=1&hd=1" type="application/x-shockwave-flash" wmode="transparent" width="546" height="390"></embed></object>';
            }
    
            var newElement = '<div class="video hidden" id="' + dataId + '"><div class="close minimize hidden"></div><div class="player">' + embedPlayer + '</div><div class="info"><div style="background: url(/images/icons/youtube-24.png) no-repeat center" class="logo"></div><span class="videoTitle">' + data.feed.entry[0].title.$t + '</span></div></div>';
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



  
  // Add youtube icon after each youtube, soundcloud & vimeo link
  $('.content .body, .commentsPanel').find('a.youtube, a.soundcloud, a.vimeo').filter(function(){
    return this.hostname && this.hostname !== location.hostname;
  }).prepend('<div class="img"></div>')
  
  // WILL NEED TO FIGURE OUT A WAY TO COMBINE ALL OF THESE
  // AND MAKE THEM WORK EASILY W ALL NEW EMBED TYPES!
  
  // Set click event for youtube links
  $('.content .body, .commentsPanel').find('a.youtube').click(function(event){
    event.preventDefault()
    var embedVideo = String("#youtube-" + $(event.currentTarget).data('id'));
    $(embedVideo).show()
  })

  // Set click event for soundcloud links
  $('.content .body, .commentsPanel').find('a.soundcloud').click(function(event){
    event.preventDefault()
    var embedVideo = String("#soundcloud-" + $(event.currentTarget).data('id'));
    $(embedVideo).show()
  })
  
  // Set click event for vimeo links
  $('.content .body, .commentsPanel').find('a.vimeo').click(function(event){
    event.preventDefault()
    var embedVideo = String("#vimeo-" + $(event.currentTarget).data('id'));
    $(embedVideo).show()
  })
    
}

function getOffset( el ) {
    var _x = 0;
    var _y = 0;
    while( el && !isNaN( el.offsetLeft ) && !isNaN( el.offsetTop ) ) {
        _x += el.offsetLeft - el.scrollLeft;
        _y += el.offsetTop - el.scrollTop;
        el = el.offsetParent;
    }
    return { top: _y, left: _x };
}


function linkify(text)
  {
    if( !text ) return text;
    
    text = text.replace(/(https?\:\/\/|ftp\:\/\/|www\.)[\w\.\-_]+(:[0-9]+)?\/?([\w#!:.?+=&(&amp;)%@!\-\/])*/gi, function(url){
      nice = url;
      if( url.match('^https?:\/\/') )
      {
        nice = nice.replace(/^https?:\/\//i,'')
      }
      else
        url = 'http://'+url;
      
      var urlTitle = nice.replace(/^www./i,'');
      return '<a target="_blank" rel="nofollow" href="'+ url +'">'+ url +'</a>';
    });
    
    return text;
  }

function setup2dThumbIPadClick(){
  // make iPad 1 click work on thumbs
  var ua = navigator.userAgent;
  var clickEvent;
  if (ua.match(/iPad/i)){
    clickEvent = "touchstart";
  } else {
    clickEvent = "click";
  } 
  
  $('.thumb-2d a.link').bind( clickEvent, function(event){
    event.preventDefault();
    window.location = $(event.currentTarget).attr('href');
  })
}



var uploader = null;
var imageMetaParams = { image: {"section":"user_uploaded", "category": "new_dream"} };

function setupUploader(){      
  if(document.getElementById('imageDropArea')){
    // Setup radio button events
    
    $('.entryImageContainer input[type=radio]').live('change', function(){
      $('.entryImageContainer .radio').removeClass('selected')
      $(this).parent().addClass('selected')
    })
    
    uploader = new qq.FileUploader({
      element: document.getElementById('imageDropArea'),
      action: '/images.json',
      maxConnections: 1,
      params: imageMetaParams,
      debug: true,
      onSubmit: function(id, fileName){
     
      },
      onComplete: function(id, fileName, responseJSON){
        //setupImageButtons();
      }
    });
  }      
}


function setupImagebank(){
  $('#addFromImageBank').click(function(){
    displayImageBank();
  });
}

function displayImageBank(){
  var filePath = '/images';
  $.ajax({
    url: filePath,
    dataType: 'html',
    success: function(data) {
      //var newElement = '<div class="linkContainer"><div class="title"><input class="linkTitleValue" value="' + data.feed.entry[0].title.$t + '" /></div><div class="url"><a href="' + newText + '">' + newText + '</a></div><div class="removeicon">X</div><div class="icon"><img src="http://www.google.com/s2/favicons?domain_url=' + newText + '" /></div></div>';
      $('body').append(data);
      $('#IB_browser_frame').fadeIn();
      
      // Initialize imagebank w/ sectionFilter (Library, Bedsheets, etc...)
      initImageBank('Library');
    }
  });
}

//************************************//
//            TAG HANDLING            //
//************************************//

//*********** ADDING TAGS ***********//
        
// ADDS DATA TO TAG LIST
function addTagToListDream(tagToAdd,tagType,tagInputBoxIdd){
  var tag_selected =  tagToAdd; // set selected city to be the same as contents of the selected city
  var tag_type =  tagType; // type of tag (tag/thread/emotion/place/person/etc.)

  var randomNumber = Math.round( Math.random() * 100001) ; // Generate ID
  var tagID = 'tagID_' + randomNumber ; // Define ID for New Region
  var tagID_element = '#' + tagID ; // Create variable to handle the ID

  if (tag_selected != ''){ // if it's not empty
    //$('#empty-tag').clone().attr('id', tagID ).appendTo('#tag-list').end; // clone tempty tag box

    var newElement = $('#empty-tag').clone().attr('id', tagID );
    $('#tag-list br').before(newElement);
    $(tagID_element).removeClass('hidden') ; // and unhide the new one
    $(tagID_element).addClass('current-tags');
    $(tagID_element).find('.tag-name').html( tag_selected ); // populate with tag text

    setTimeout(function() { $(tagID_element).animate({ backgroundColor: "#333" }, 'slow'); }, 200);

    /*var elementHeight = $('#tag-list').height();
    //$('#tag-list').css('height', elementHeight + 'px');

    var combinedHeight = elementHeight;
    $('#newDream-tag').animate({height: combinedHeight}, "fast", function(){
      var elementHeight = $('#tag-list').height();
    });*/

  }


  $(tagInputBoxIdd).val(''); // Clear textbox
  $(tagInputBoxIdd).focus(); // Focus text input

  //$(tagInputBoxIdd).autocomplete( 'close' );

  activateRemoveDreamTag('.tag_box');

  // Update on server
  if(tagInputBoxIdd == "#IB_tagText"){
    //updateCurrentImageTags();
  }

  //$(tagID_element).addClass('tag_box_pop', 1000);

  return false;


 };


//*********** REMOVING TAGS ***********//

function activateRemoveDreamTag (context) {

}


// REMOVES DATA FROM TAG LIST
function removeTagFromDreamList (idd){
  /*$(idd).addClass('kill_tag');

  setTimeout(function() { $(idd).addClass('opacity-50', 0 ); }, 250);
  setTimeout(function() { $(idd).fadeOut('fast'); }, 300);
  setTimeout(function() { $(idd).remove(); }, 400);*/
  
  //updateCurrentImageTags();

};

/*** END OF TAGS ***/

var tagHeight;

function checkAttachButtons(){
  var buttonVisible = false;
  $('.entryAttach .attach').each(function(i, el){
    // Go thru each button and see if they are all hidden
    if($(this).css('display') != 'none'){
      buttonVisible = true
    }
  })
  
  if(!buttonVisible){
    $('.entryAttach').fadeOut();
  } else {
    $('.entryAttach').fadeIn()
  }
}

function setupEvents(){
  // Listen for attach toggles
  $('.entryAttach .images').unbind();
  $('.entryAttach .images').click(function(){
    $('.entryImages').slideDown();
    $(this).hide();

    checkAttachButtons();
  })
  
  // Set newly displayed header click
  $('.imagesHeader').unbind()
  $('.imagesHeader').click(function(){
    // if no images added, remove panel 
    // and show button
    if($('#currentImages').children().length == 1){
      $('.entryImages').slideUp();
      $('.entryAttach .images').show();
    } else {
      // if content added, minimize panel
      if($('#currentImages').css('display') != 'none'){
        $('#currentImages').slideUp();
      } else {
        $('#currentImages').slideDown();
      }
    }
    checkAttachButtons();
  })
  
  $('.entryAttach .tag').unbind();
  $('.entryAttach .tag').click(function(){
    $('.entryTags').slideDown();
    //$('#newDream-tag').height(0);
    //$('#newDream-tag').css('display', 'block');
    //$('#newDream-tag').animate({height: 42}, "slow");
    
    $(this).hide();
    checkAttachButtons();
  })
  
  // Set newly displayed header click
  $('.entryTags .headers').unbind();
  $('.entryTags .headers').click(function(){
    if($('#tag-list').children().length == 2){
      // No tags added hide it all
      $('.entryTags').slideUp();
      $('.entryAttach .tag').show();
    } else {
      // tags added only minimize
      if($('#tag-list').css('display') != 'none'){
        var elementHeight = $('#tag-list').height(); 
        $('#tag-list').css('height', elementHeight + 'px');
        $('#tag-list').slideUp('fast');
        
        /*var combinedHeight = elementHeight;
        $('#newDream-tag').height(combinedHeight);
        $('#newDream-tag').animate({height: 42}, "fast");*/
      } else {
        var elementHeight = $('#tag-list').height(); 
        $('#tag-list').css('height', elementHeight + 'px');
        $('#tag-list').slideDown('fast');
        
        /*var combinedHeight = 50 + elementHeight;
        $('#newDream-tag').height(42);
        $('#newDream-tag').animate({height: combinedHeight}, "fast");*/
      }
    }
    checkAttachButtons();
  })
  
  // Setup mood picker
  $('.emotionPanel input').change(function(event){
    $(this).parent().parent().find('label').removeClass('selected')
    $(this).parent().addClass('selected')
  })
  
  $('.entryAttach .emotions').unbind();
  $('.entryAttach .emotions').click(function(){
    $('.entryEmotions').slideDown();
    $(this).hide();
    checkAttachButtons();
  })
  
  $('.entryEmotions .headers').unbind()
  $('.entryEmotions .headers').click(function(){
    var radioSelected = false;
    $('.entryEmotions input[type="radio"]:checked').each(function(i, el){
      // only mark as selected if its a value other than 1
      if($(el).val() != '0'){
        radioSelected = true
      }
    })
    
    if(radioSelected){
      if($('.emotionPanel').css('display') == 'none'){
        $('.emotionPanel').slideDown()
      } else {
        $('.emotionPanel').slideUp()
      }
    } else {
      $('.entryEmotions').slideUp();
      $('.entryAttach .emotions').show();
    }
    
    checkAttachButtons();
  })
  
  $('.entryAttach .links').unbind();
  $('.entryAttach .links').click(function(){
    $('.entryLinks').slideDown();
    $(this).hide();
    checkAttachButtons();
  })
  
  // Set newly displayed header click
  $('.entryLinks .headers').unbind();
  $('.entryLinks .headers').click(function(){
    if($('#linkHolder').children().length < 1){
      // No tags added hide it all
      $('.entryLinks').slideUp();
      $('.entryAttach .links').show();
    } else {
      // tags added only minimize
      if($('#linkHolder').css('display') != 'none'){
        $('#linkHolder').slideUp();
      } else {
        $('#linkHolder').slideDown();
      }
    }
    checkAttachButtons();
  })
  
  $('#entry-date').unbind();
  $('#entry-date, .dateTimeHeader').click(function(){
    if($('.entryDateTime').css('display') == 'none'){
      $('.entryDateTime').slideDown();
    } else {
      $('.entryDateTime').slideUp();
    }
  })
  
  // Listen for paste in DREAM field
  /*$("#entry_body").bind('paste', function(e) {
    // Get pasted link
    // THIS NEEDS WORK!
    setTimeout(function() {
      var text = $('textarea#entry_body').val()
      var length = text.length;
      var index = text.search(/http:(?!.*http:)/);
      var url = text.slice(index, length);
      checkForPastedLink(url)
    }, 100);
    
  });*/
  
  // Listen for paste in LINK field
  $('.linkAdd').click(function() {
    setTimeout('checkForPastedLink($("#linkValue").val())', 400);
  });
  
  $('#linkValue').keypress(function(e) {
    if(e.keyCode == 13) {
      e.preventDefault()
      e.stopPropagation()
      setTimeout('checkForPastedLink($("#linkValue").val())', 400);
      return false;
    }
  });
  
  // Remove link listener
  $('.removeicon').live("click", function(){
    $(this).parent().fadeOut('fast', function(){
      $(this).remove();
    });
  })

  
  setupImageButtons();
}

function checkForPastedLink(newText){
  $('#linkValue').val('');
  //var regexp = /(http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
  var regexp = /[-a-zA-Z0-9@:%_\+.~#?&//=]{2,256}\.[a-z]{2,4}\b(\/[-a-zA-Z0-9@:%_\+.~#?&//=]*)?/gi;
  if(regexp.test(newText)){
    // Check for http at start (add if not there)
    var tempURL = newText.substring(0,4);
    if(tempURL != 'http'){
      newText = "http://" + newText;
    }
    
    // Post link
    addLink(newText)
  }
}

function addLink(newText){
  if($('.entryLinks').css('display') == 'none'){
    $('.entryLinks').slideDown();
    $('.entryAttach .links').hide();
    
    // Set newly displayed header click
    $('.entryLinks .headers').unbind();
    $('.entryLinks .headers').click(function(){
      if($('#linkHolder').children().length < 1){
        // No tags added hide it all
        $('.entryLinks').slideUp();
        $('.entryAttach .links').show();
      } else {
        // tags added only minimize
        if($('#linkHolder').css('display') != 'none'){
          $('#linkHolder').slideUp();
        } else {
          $('#linkHolder').slideDown();
        }
      }
    })
  }
  // Check what DOMAIN they are pasting
  var tempAnchor = $("<a />");
  tempAnchor.attr('href', newText)
  var hostname = tempAnchor.attr('hostname'); // http://example.com
  
  // Check if it a non video youtube link (no v=)
  if((newText.indexOf("v=") == -1) && (hostname.indexOf("youtube.com") != -1)){
    hostname = "dreamcatcher.net"
  }
  
  switch(hostname){
    case "youtube.com":
        showYoutubeData(newText);
      break;
    
    case "www.youtube.com":
        showYoutubeData(newText);
      break;
      
    default:
        var randomNumber = Math.round( Math.random() * 100001) ; // Generate ID
        var newID = 'link-' + randomNumber;
        var newEle = '#' + newID;
        var newDOM = $(newEle);
        var newElement = '<div id="' + newID + '" class="linkContainer"><div class="title"><input value="link title" style="width: 220px;" name="links[][title]" class="linkTitleValue"></div><div class="url"><input value="' + newText + '" class="linkTitleValue" name="links[][url]" style="width: 320px;"><div class="icon"><img src="http://www.google.com/s2/favicons?domain_url=' + newText + '" /></div></div><div class="close"></div></div>';
        $('#linkHolder').append(newElement);
        var dataSent = {url: newText};
        // Get the title from server
        var filePath = '/parse/title'
        $.ajax({
          url: filePath,
          context: $(newEle),
          data: dataSent,
          success: function(data) {
            $(this).find('.title .linkTitleValue').val(data.title)
            $('.linkContainer').fadeIn();
          }
        });
      break;
      
  }
}

function showYoutubeData(newText){
  // Find the Video ID number
  var splitTextArray = newText.split('v=');
  var filePath = 'http://gdata.youtube.com/feeds/api/videos?q=' + splitTextArray[splitTextArray.length - 1] + '&alt=json&max-results=30&format=5';
  
  // Get the data from YOUTUBE
  $.ajax({
    url: filePath,
    dataType: 'jsonp',
    success: function(data) {
      if(typeof data.feed.entry != 'undefined' && data.feed.entry != null){
        var ua = navigator.userAgent
        if(ua.match(/iPad/i)){
          // IPAD Server HTML5 player
          var videoArray = data.feed.entry[0].id.$t.split('/')
          var video_id = videoArray[videoArray.length - 1]
          var embedPlayer = '<iframe class="youtube-player" type="text/html" width="614" height="390" src="http://www.youtube.com/embed/' + video_id + '" frameborder="0"></iframe>'
        } else {
          // Normal flash w/ autoplay
          var videoPath = data.feed.entry[0].media$group.media$content[0].url;
          var embedPlayer = '<object width="614" height="390"><param name="movie" value="' + videoPath + '&autoplay=1&hd=1"></param><param name="wmode" value="transparent"></param><embed src="' + videoPath + '&autoplay=1&hd=1" type="application/x-shockwave-flash" wmode="transparent" width="614" height="390"></embed></object>';
        }
        //var videoPath = data.feed.entry[0].media$group.media$content[0].url;
        //var embedPlayer = '<object width="425" height="350"><param name="movie" value="' + videoPath + '"></param><param name="wmode" value="transparent"></param><embed src="' + videoPath + '" type="application/x-shockwave-flash" wmode="transparent" width="425" height="350"></embed></object>';
        var newElement = '<div class="linkContainer youtube"><div class="title"><input class="linkTitleValue" style="width: 220px;" value="' + data.feed.entry[0].title.$t + '" name="links[][title]" /></div><div class="url"><input value="' + newText + '" class="linkUrlValue" name="links[][url]" style="width: 320px;"><div class="icon"><img src="http://www.google.com/s2/favicons?domain_url=' + newText + '" /></div></div><div class="close"></div><div class="thumb" style="background: url(' + data.feed.entry[0].media$group.media$thumbnail[1].url + ') no-repeat center center transparent"></div><div class="description">' + data.feed.entry[0].content.$t + '</div></div>';
        $('#linkHolder').append(newElement);
        $('#linkHolder').slideDown()
        $('.linkContainer').fadeIn();
      } else {
        var randomNumber = Math.round( Math.random() * 100001) ; // Generate ID
        var newID = 'link-' + randomNumber;
        var newEle = '#' + newID;
        var newDOM = $(newEle);
        
        var newElement = '<div id="' + newID + '" class="linkContainer"><div class="title"><input value="Youtube Video" style="width: 220px;" name="links[][title]" class="linkTitleValue"></div><div class="url"><input value="' + newText + '" class="linkTitleValue" name="links[][url]" style="width: 320px;"><div class="icon"><img src="http://www.google.com/s2/favicons?domain_url=' + newText + '" /></div></div><div class="close"></div></div>';
        $('#linkHolder').append(newElement);
        
        var dataSent = {url: newText};
        // Get the title from server
        var filePath = '/parse/title'
        $.ajax({
          url: filePath,
          context: $(newEle),
          data: dataSent,
          success: function(data) {
            $(this).find('.title .linkTitleValue').val(data.title)
            $('.linkContainer').fadeIn();
          }
        });
      }
    }
  });
}

function setupImageButtons(){
  // Click to remove Image
  $('#currentImages .close').live('click', function(event){
    // Remove from list of used images
    var currentImageId = $(this).parent().parent().data('id');
    
    $('.image_upload').each(function(i, element){
      if($(this).val() == currentImageId){
        $(this).remove()
      }
    })
    
    $(this).parent().parent().fadeOut('fast', function(){
      $(this).remove();
    });
    
  })
}

function setupLinkButtons(){
  // Click to remove link
  $('#linkHolder .close').live('click', function(event){
    // Remove from list of used link  
    $(event.currentTarget).parent().slideUp(250, function(){
      $(this).remove()
    })
  })
}



