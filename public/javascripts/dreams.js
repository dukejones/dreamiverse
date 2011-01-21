$(document).ready(function() {
  setupEvents();
});

function setupEvents(){
  // Listen for images toggle
  $('#attach-images').unbind();
  $('#attach-images').toggle(function(){
    $('#new_dream-images').slideDown();
  }, function(){
    $('#new_dream-images').slideUp();
  })
  
  // Listen for paste in LINK field
  $("#linkInputWrap input").bind('paste', function() {
    setTimeout('checkForPastedLink($("#linkValue").val())', 400)
    
  });

  
  resetImageButtons();
}

function checkForPastedLink(newText){
  var regexp = /(http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
  if(regexp.test(newText)){
    alert('is link')
  } else {
    alert('not link')
  }
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