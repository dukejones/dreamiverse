$(document).ready(function(){
  initContextMenu();
})

var friendsExpanded = false;

function initContextMenu(){
  // Setup friends expander
  $('.friends').bind('mouseenter', function (e) {
    if(!friendsExpanded){
      $(this).find('.expander').slideDown(500, function(){
        friendsExpanded = true;
      });
    }
  })
  .bind('mouseleave', function (e) {
    $(this).find('.expander').slideUp(500, function(){
      friendsExpanded = false;
    });
  })
}