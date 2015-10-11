$(document).ready(function(){
  setupFriendsElements();
})

function setupFriendsElements(){
  // Hover to display status
  $('.userNode').hover(function(){
    $(this).find('.statusHover').fadeIn('fast');
    
    $(this).find('.statusHover').unbind();
    $(this).find('.statusHover').click(function(){
      if($(this).find('span').text() == 'unfollow'){
        $(this).parent().find('.status').css('background-position', '0 0%')
        $(this).find('span').text('follow');
      } else if($(this).find('span').text() == 'follow'){
        $(this).parent().find('.status').css('background-position', '0 33%')
        $(this).find('span').text('unfollow');
      }
    })
  }, function(){
    $(this).find('.statusHover').fadeOut('fast');
  })
  
 // Click to expand node
 $('.userNode .backdrop, .userNode .userInfo').click(function(){
   if($(this).parent().find('.expanded').css('display') == 'none'){
     // Expand user node
     var oldZ = $(this).parent().css('z-index');
     var newZ = Number(oldZ) + 1;
     $(this).parent().css('z-index', newZ);
     $(this).parent().find('.expanded').slideDown();
   } else {
     $(this).parent().find('.expanded').slideUp(100);
   }
 })
 
 
}