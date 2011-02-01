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
        $(this).parent().find('.userStatus').css('background-position', '0 0%')
        $(this).find('span').text('follow');
      } else if($(this).find('span').text() == 'follow'){
        $(this).parent().find('.userStatus').css('background-position', '0 33%')
        $(this).find('span').text('unfollow');
      }
    })
  }, function(){
    $(this).find('.statusHover').fadeOut('fast');
  })
 // Click to expand node
 $('.user .userInfo').find('h3').click(function(){
   if($(this).parent().parent().find('.expanded').css('display') == 'none'){
     // Expand user node
     $(this).parent().parent().find('.close').click(function(){
       $(this).parent().slideUp();
     })
     $(this).parent().parent().find('.expanded').slideDown();
   } else {
     $(this).parent().parent().find('.expanded').slideUp();
   }
 })
 
 
}