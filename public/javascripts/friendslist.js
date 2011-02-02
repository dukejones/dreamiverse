$(document).ready(function(){
  setupFriendsElements();
})

function setupFriendsElements(){
  // Hover to display status
  $('.user').hover(function(){
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
 $('.user').click(function(){
   if($(this).find('.expanded').css('display') == 'none'){
     // Expand user node
     $(this).addClass('z-top');
     $(this).find('.close').click(function(){
       $(this).slideUp();
     })
     $(this).find('.expanded').slideDown();
   } else {
     $(this).find('.expanded').slideUp();
     $(this).removeClass('z-top');
   }
 })
 
 
}