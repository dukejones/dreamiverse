$(document).ready(function() {
  setupEvents();
  setupImagebank();
  setupTextareaAutoExpander();
  setupUploader();
  setupSharingImages()
});

function setupSharingImages(){
  $('.detailsBottom .sharing span').each(function(){
    switch($(this).text()){
      case 'private':
          $(this).prev().attr('src', '/images/icons/lock-16.png')
        break;
      case 'anonymous':
          $(this).prev().attr('src', '/images/icons/mask-16.png')
        break;
      case 'users':
          $(this).prev().attr('src', '/images/icons/listofUsers-16.png')
        break;
      case 'followers':
          $(this).prev().attr('src', '/images/icons/friend-follower-16')
        break;
      case 'friends':
          $(this).prev().attr('src', '/images/icons/friend-16.png')
        break;
      case 'friends of friends':
          $(this).prev().attr('src', '/images/icons/friend-16.png')
        break;
      case 'everyone':
          $(this).prev().attr('src', '/images/icons/everyone-grey-16.png')
        break;
    }
  })
}

var uploader = null;
var imageMetaParams = { image: {"section":"user_uploaded", "category": "new_dream"} };

function setupUploader(){      
  if(document.getElementById('imageDropArea')){
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

function setupTextareaAutoExpander(){
  // Setup entry_body input expander
  if($('textarea#entry_body').attr('id') == 'entry_body'){
    $('textarea#entry_body').autoResize({
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
    }).trigger('change'); // resizes the form initially
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
    $(tagID_element).find('.tagContent').html( tag_selected ); // populate with tag text
    
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

function setupEvents(){
  // Listen for attach toggles
  $('.entryAttach .images').unbind();
  $('.entryAttach .images').click(function(){
    $('.entryImages').slideDown();
    $(this).hide();
    
    // Set newly displayed header click
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
    })
    
  })
  
  $('.entryAttach .tag').unbind();
  $('.entryAttach .tag').click(function(){
    $('.entryTags').slideDown();
    //$('#newDream-tag').height(0);
    //$('#newDream-tag').css('display', 'block');
    //$('#newDream-tag').animate({height: 42}, "slow");
    
    $(this).hide();
    
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
    })
  })
  
  $('.entryAttach .mood').unbind();
  $('.entryAttach .mood').click(function(){
    $('.entryMood').slideDown();
    $(this).hide();
    
    $('.entryMood .headers').click(function(){
      $('.entryMood').slideUp();
      $('.entryAttach .mood').show();
    })
  })
  
  $('.entryAttach .links').unbind();
  $('.entryAttach .links').click(function(){
    $('.entryLinks').slideDown();
    $(this).hide();
    
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
  })
  
  $('#entryOptions .date').unbind();
  $('#entryOptions .date, .dateTimeHeader').click(function(){
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
      //var text = el.val();
      //#checkForPastedLink(text)
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
  var regexp = /(http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
  if(regexp.test(newText)){
    addLink(newText)
  }
}

function addLink(newText){
  if($('#newDream-link').css('display') == 'none'){
    $('#newDream-link').slideDown();
    $('.entryAttach .links').hide();
    
    // Set newly displayed header click
    $('#newDream-link .headers').unbind();
    $('#newDream-link .headers').click(function(){
      if($('#linkHolder').children().length < 1){
        // No tags added hide it all
        $('#newDream-link').slideUp();
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
        var newElement = '<div id="' + newID + '" class="linkContainer"><div class="title"><input value="link title" style="width: 220px;" name="entry[links_attributes][][title]" class="linkTitleValue"></div><div class="url"><input value="' + newText + '" class="linkTitleValue" name="entry[links_attributes][][url]" style="width: 320px;"><div class="icon"><img src="http://www.google.com/s2/favicons?domain_url=' + newText + '" /></div></div><div class="removeicon">x</div></div>';
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
      var newElement = '<div class="linkContainer"><div class="thumb"><img width="120" height="90" src="' + data.feed.entry[0].media$group.media$thumbnail[0].url + '" /></div><div class="title"><input class="linkTitleValue" value="' + data.feed.entry[0].title.$t + '" /></div><div class="url"><input value="' + newText + '" class="linkTitleValue" name="entry[links_attributes][][url]" style="width: 320px;"></div><div class="removeicon">X</div><div class="icon"><img src="http://www.google.com/s2/favicons?domain_url=' + newText + '" /></div></div>';
      $('#linkHolder').append(newElement);
      $('.linkContainer').fadeIn();
    }
  });
}

function setupImageButtons(){
  // Click to remove Image
  $('.imageRemoveButton').live('click', function(event){
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
  
  // Click to expand/contract image
  /*$('.entryImage').unbind();
   $('.entryImage').click(function(){
     if($(this).hasClass('round-8')){
       // Expand me
       
       // Close all other dream images that are open
      $('.entryImageContainer').each(function(){
        if(!$(this).find('.entryImage').hasClass('round-8')){
          $(this).animate({width: '120px'}, 400, function(){
            // Complete
            $(this).find('.entryImage').removeClass('round-8-left');
            $(this).find('.entryImage').addClass('round-8');
          });
          $(this).find('.entryImage').animate({width: '120px'});
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
   });*/
}