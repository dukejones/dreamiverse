$(document).ready(function(){
  initContextMenu();
})

function initContextMenu(){
  // Setup friends expander
  $('.friends').click(function(){
    $(this).next().slideDown();
  })
}