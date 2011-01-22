$(document).ready(function() {
  setupEvents();
});

function setupEvents(){
  // Listen for attach toggles
  $('#attach-images').unbind();
  $('#attach-images').toggle(function(){
    $('#new_dream-images').slideDown();
  }, function(){
    $('#new_dream-images').slideUp();
  })
  
  $('#newDream-attach .tag').unbind();
  $('#newDream-attach .tag').toggle(function(){
    $('#newDream-tag').slideDown();
  }, function(){
    $('#newDream-tag').slideUp();
  })
  
  $('#newDream-attach .mood').unbind();
  $('#newDream-attach .mood').toggle(function(){
    $('#newDream-mood').slideDown();
  }, function(){
    $('#newDream-mood').slideUp();
  })
  
  $('#newDream-attach .links').unbind();
  $('#newDream-attach .links').toggle(function(){
    $('#newDream-link').slideDown();
  }, function(){
    $('#newDream-link').slideUp();
  })
  
  $('#newDream-attach .analysis').unbind();
  $('#newDream-attach .analysis').toggle(function(){
    $('#newDream-analysis').slideDown();
  }, function(){
    $('#newDream-analysis').slideUp();
  })
  
  // Listen for paste in DREAM field
  $("#dream_body").bind('paste', function() {
    setTimeout('checkForPastedLink($("#dream_body").val())', 400)
    
  });
  
  // Listen for paste in LINK field
  $('#linkAdd').click(function() {
    setTimeout('checkForPastedLink($("#linkValue").val())', 400);
  });

  
  resetImageButtons();
}

function checkForPastedLink(newText){
  $('#linkValue').val('');
  var regexp = /(http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
  if(regexp.test(newText)){
    addLink(newText)
  }
}

function addLink(newText){
  // Check what DOMAIN they are pasting
  var tempAnchor = $("<a />");
  tempAnchor.attr('href', newText)
  var hostname = tempAnchor.attr('hostname'); // http://example.com
  
  switch(hostname){
    case "youtube.com":
        showYoutubeData(newText);
      break;
    
    case "www.youtube.com":
        showYoutubeData(newText);
      break;
      
    default:
        var newElement = '<div class="linkContainer"><div class="title"><input class="linkTitleValue" value="' + "Link Title" + '" /></div><div class="url"><a href="' + newText + '">' + newText + '</a></div><div class="removeicon">X</div><div class="icon"><img src="http://www.google.com/s2/favicons?domain_url=' + newText + '" /></div></div>';
        $('#newDream-link').append(newElement);
        $('.linkContainer').fadeIn();
      break;
      
  }
  
  $('.removeicon').click(function(){
    $(this).parent().fadeOut('fast', function(){
      $(this).remove();
    });
  })

  
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
      var newElement = '<div class="linkContainer"><div class="title"><input class="linkTitleValue" value="' + data.feed.entry[0].title.$t + '" /></div><div class="url"><a href="' + newText + '">' + newText + '</a></div><div class="removeicon">X</div><div class="icon"><img src="http://www.google.com/s2/favicons?domain_url=' + newText + '" /></div></div>';
      $('#newDream-link').append(newElement);
      $('.linkContainer').fadeIn();
    }
  });
}

function resetImageButtons(){
  // Click to remove Image
  $('.imageRemoveButton').click(function(){
    // Remove from list of used images
    $(this).parent().parent().fadeOut();
  })
  
  // Click to expand/contract image
  $('.dreamImage').unbind();
   $('.dreamImage').click(function(){
     if($(this).hasClass('round-8')){
       // Expand me
       
       // Close all other dream images that are open
      $('.dreamImageContainer').each(function(){
        if(!$(this).find('.dreamImage').hasClass('round-8')){
          $(this).animate({width: '120px'}, 400, function(){
            // Complete
            $(this).find('.dreamImage').removeClass('round-8-left');
            $(this).find('.dreamImage').addClass('round-8');
          });
          $(this).find('.dreamImage').animate({width: '120px'});
        }
      });
      
      $this = $(this);
      $(this).parent().animate({width: '375px'}, 400, function(){
        // Complete
        $this.removeClass('round-8');
        $this.addClass('round-8-left');
      });
      $(this).animate({width: '145px'});
    
     } else {
      // Contract me
      $this = $(this);
      $(this).parent().animate({width: '120px'}, 400, function(){
        // Complete
        $this.removeClass('round-8-left');
        $this.addClass('round-8');
      });
      $(this).animate({width: '120px'});
     }
   });
}