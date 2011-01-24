$(document).ready(function() {
  setupEvents();
  setupTags();
});

function setupTags(){
  // Add tag click
  $('#tagAdd').click(function(){
    addTagToList( $('#newTag').val(), 'newTag', '#newTag' );
  })
  
  // Capture ENTER press
  $($('#newTag')).keypress(function (e) {
    if (e.which == 13){
     addTagToList( $('#newTag').val(), 'newTag', '#newTag' );
    }
    activateRemoveTag('.tag_box');
  });
  
  // Set up tag list sortability
  $( "#tag-list" ).sortable( {
    distance: 10,
    start: function(event, ui) { $("#sorting").val(1) }, // while sorting, change hidden value to 1
    stop: function(event, ui) { $("#sorting").val(0) }, // on ending, change the value back to 0
  } ); // this prevents the tag from being deleted when it's dragged
}

//************************************//
//            TAG HANDLING            //
//************************************//

//*********** ADDING TAGS ***********//
        
// ADDS DATA TO TAG LIST
function addTagToList(tagToAdd,tagType,tagInputBoxIdd){
  //alert("addTagToList() " + tagToAdd)
  var tag_selected =  tagToAdd; // set selected city to be the same as contents of the selected city
  var tag_type =  tagType; // type of tag (tag/thread/emotion/place/person/etc.)

  var randomNumber = Math.round( Math.random() * 100001) ; // Generate ID
  var tagID = 'tagID_' + randomNumber ; // Define ID for New Region
  var tagID_element = '#' + tagID ; // Create variable to handle the ID
  
  if (tag_selected != ''){ // if it's not empty
    $('#empty-tag').clone().attr('id', tagID ).appendTo('#tag-list').end; // clone tempty tag box
    $(tagID_element).removeClass('hidden') ; // and unhide the new one
    $(tagID_element).addClass('current-tags');
    //$(tagID_element).contents().find('.tag-icon').addClass( tag_type ); // populate with tag icon
    $(tagID_element).find('.content').html( tag_selected ); // populate with tag text
    
    $(tagID_element).css('background-color', '#ccc');
    setTimeout(function() { $(tagID_element).animate({ backgroundColor: "#333" }, 'slow'); }, 200);
    
    
  }
  
  
  $(tagInputBoxIdd).val(''); // Clear textbox
  $(tagInputBoxIdd).focus(); // Focus text input
  
  //$(tagInputBoxIdd).autocomplete( 'close' );
  
  activateRemoveTag('.tag_box');
  
  // Update on server
  if(tagInputBoxIdd == "#IB_tagText"){
    //updateCurrentImageTags();
  }
  
  //$(tagID_element).addClass('tag_box_pop', 1000);
  
  return false;
    
            
 };


//*********** REMOVING TAGS ***********//  

function activateRemoveTag (context) {
  $(context).mouseup(function() {
    //alert('this :: ' + $('#sorting').val())
    if ($("#sorting").val() == 0)
      removeTagFromList(this);
  }); 
  
}

$(function() {
  activateRemoveTag('.tag_box');
});

// REMOVES DATA FROM TAG LIST          
function removeTagFromList (idd){
  
  //$(idd).removeClass('tag_box', 0 );
  $(idd).addClass('kill_tag');
  
  setTimeout(function() { $(idd).addClass('opacity-50', 0 ); }, 250);
  setTimeout(function() { $(idd).fadeOut('fast'); }, 300);
  
  //updateCurrentImageTags();

};

/*** END OF TAGS ***/


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