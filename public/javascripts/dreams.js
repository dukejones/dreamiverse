$(document).ready(function() {
  setupEvents();
  setupTags();
  setupImagebank();
  setupTextareaAutoExpander();
  setupUploader();
});

var uploader = null;
var imageMetaParams = { image: {"section":"user_uploaded", "category": "new_dream"} };

function setupUploader(){            
  uploader = new qq.FileUploader({
    element: document.getElementById('imageDropArea'),
    action: '/images.json',
    maxConnections: 1,
    params: imageMetaParams,
    debug: true,
    onSubmit: function(id, fileName){
     alert('image uploading')
    },
    onComplete: function(id, fileName, responseJSON){
      if(responseJSON.success){
        // Image made it
        // Get image info from
        // responseJSON.id
        alert('image uploaded');
      }
      
    }
  });           
}

function setupTextareaAutoExpander(){
  if($('textarea#dream_body').attr('id') == 'dream_body'){
    $('textarea#dream_body').autoResize({
      // On resize:
      onResize : function() {
          $(this).css({opacity:0.8});
      },
      // After resize:
      animateCallback : function() {
          $(this).css({opacity:1});
      },
      // Quite slow animation:
      animateDuration : 500,
      animate: true,
      // More extra space:
      extraSpace : 40
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

function setupTags(){
  // Add tag click
  $('#tagAdd').click(function(){
    addTagToListDream( $('#newTag').val(), 'newTag', '#newTag' );
  })
  
  // Capture ENTER press
  $($('#newTag')).keypress(function (e) {
    if (e.which == 13){
     addTagToListDream( $('#newTag').val(), 'newTag', '#newTag' );
    }
    activateRemoveDreamTag('.tag_box');
  });
  
  // Set up tag list sortability
  /*$( "#tag-list" ).sortable( {
    distance: 10,
    start: function(event, ui) { $("#sorting").val(1) }, // while sorting, change hidden value to 1
    stop: function(event, ui) { $("#sorting").val(0) }, // on ending, change the value back to 0
  } );*/ // this prevents the tag from being deleted when it's dragged
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
    $(tagID_element).find('.content').html( tag_selected ); // populate with tag text
    
    $(tagID_element).css('background-color', '#ccc');
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
  $(context).mouseup(function() {
    //alert('this :: ' + $('#sorting').val())
    if ($("#sorting").val() == 0)
      removeTagFromDreamList(this);
  }); 
  
}

$(function() {
  activateRemoveDreamTag('.tag_box');
});

// REMOVES DATA FROM TAG LIST          
function removeTagFromDreamList (idd){
  $(idd).addClass('kill_tag');
  
  setTimeout(function() { $(idd).addClass('opacity-50', 0 ); }, 250);
  setTimeout(function() { $(idd).fadeOut('fast'); }, 300);
  setTimeout(function() { $(idd).remove(); }, 400);
  
  //updateCurrentImageTags();

};

/*** END OF TAGS ***/

var tagHeight;

function setupEvents(){
  // Listen for attach toggles
  $('#attach-images').unbind();
  $('#attach-images').click(function(){
    $('#new_dream-images').slideDown();
    $(this).hide();
    
    // Set newly displayed header click
    $('.imagesHeader').click(function(){
      // if no images added, remove panel 
      // and show button
      if($('#currentImages').children().length == 1){
        $('#new_dream-images').slideUp();
        $('#attach-images').show();
      } else {
        // if content added, minimize panel
        if($('#currentImages').css('display') != 'none'){
          $('#currentImages').slideUp();
        } else {
          $('#currentImages').slideDown();
        }
      }
    })
    
  })
  
  $('#newDream-attach .tag').unbind();
  $('#newDream-attach .tag').click(function(){
    $('#newDream-tag').slideDown();
    //$('#newDream-tag').height(0);
    //$('#newDream-tag').css('display', 'block');
    //$('#newDream-tag').animate({height: 42}, "slow");
    
    $(this).hide();
    
    // Set newly displayed header click
    $('#newDream-tag .headers').unbind();
    $('#newDream-tag .headers').click(function(){
      if($('#tag-list').children().length == 2){
        // No tags added hide it all
        $('#newDream-tag').slideUp();
        $('#newDream-attach .tag').show();
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
    })
  })
  
  $('#newDream-attach .mood').unbind();
  $('#newDream-attach .mood').click(function(){
    $('#newDream-mood').slideDown();
    $(this).hide();
    
    $('#newDream-mood .headers').click(function(){
      $('#newDream-mood').slideUp();
      $('#newDream-attach .mood').show();
    })
  })
  
  $('#newDream-attach .links').unbind();
  $('#newDream-attach .links').click(function(){
    $('#newDream-link').slideDown();
    $(this).hide();
    
    // Set newly displayed header click
    $('#newDream-link .headers').unbind();
    $('#newDream-link .headers').click(function(){
      if($('#linkHolder').children().length < 1){
        // No tags added hide it all
        $('#newDream-link').slideUp();
        $('#newDream-attach .links').show();
      } else {
        // tags added only minimize
        if($('#linkHolder').css('display') != 'none'){
          $('#linkHolder').slideUp();
        } else {
          $('#linkHolder').slideDown();
        }
      }
    })
  })
  
  $('#newDream-attach .analysis').unbind();
  $('#newDream-attach .analysis').toggle(function(){
    $('#newDream-analysis').slideDown();
  }, function(){
    $('#newDream-analysis').slideUp();
  })
  
  $('#entryOptions .date').unbind();
  $('#entryOptions .date').toggle(function(){
    $('#newDream-dateTime').slideDown();
  }, function(){
    $('#newDream-dateTime').slideUp();
  })
  
  // Listen for paste in DREAM field
  $("#dream_body").bind('paste', function(e) {
    // Get pasted link
    var el = $(this);
    setTimeout(function() {
      var text = $(el).val();
      checkForPastedLink(text)
    }, 100);
    
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
  if($('#newDream-link').css('display') == 'none'){
    $('#newDream-link').slideDown();
    $('#newDream-attach .links').hide();
    
    // Set newly displayed header click
    $('#newDream-link .headers').unbind();
    $('#newDream-link .headers').click(function(){
      if($('#linkHolder').children().length < 1){
        // No tags added hide it all
        $('#newDream-link').slideUp();
        $('#newDream-attach .links').show();
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
        var newElement = '<div id="' + newID + '" class="linkContainer"><div class="title"><input class="linkTitleValue" value="' + "Link Title" + '" /></div><div class="url"><a href="' + newText + '">' + newText + '</a></div><div class="removeicon">X</div><div class="icon"><img src="http://www.google.com/s2/favicons?domain_url=' + newText + '" /></div></div>';
        $('#linkHolder').append(newElement);
        //$('.linkContainer').fadeIn();
        var dataSent = {url: newText};
        // Get the title from server
        var filePath = '/parse/title'
        $.ajax({
          url: filePath,
          context: $(newEle),
          data: dataSent,
          success: function(data) {
            $(this).find('.linkTitleValue').val(data.title)
            $('.linkContainer').fadeIn();
          }
        });
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
    $(this).parent().parent().fadeOut('fast', function(){
      $(this).remove();
    });
    
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