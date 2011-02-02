$(document).ready(function(){
  initContextMenu();
})

function initContextMenu(){
  // Setup friends expander
  $('.friends').hover(function(){
    $(this).find('.expander').slideDown();
  }, function(){
    $(this).find('.expander').slideUp();
  })
}