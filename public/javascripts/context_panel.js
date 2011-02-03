$(document).ready(function(){
  initContextMenu();
})

var friendsExpanded = false;

function initContextMenu(){
  // Setup friends expander
  $('.friends').bind('mouseenter', function (e) {
    if(!friendsExpanded){
      friendsExpanded = true;
      $(this).find('.expander').slideDown(400);
    }
  })
  .bind('mouseleave', function (e) {
    $(this).find('.expander').slideUp(400, function(){
      friendsExpanded = false;
    });
  })
  .click(function(){
    window.locaiton = '/friends'
  })
}