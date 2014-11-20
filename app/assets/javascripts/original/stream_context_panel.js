$(document).ready(function(){
  initStreamContextMenu();
})

function initStreamContextMenu(){
  // Toggle expand/contract filters
  $('.filterType .type').toggle(function(){
    $(this).find('img').attr('src', '/images/icons/arrow-down-16.png');
    $(this).parent().find('.expander').slideDown();
  }, function(){
    $(this).find('img').attr('src', '/images/icons/arrow-right-16.png');
    $(this).parent().find('.expander').slideUp();
  })
}