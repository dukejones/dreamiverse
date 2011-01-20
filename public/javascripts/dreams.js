$(document).ready(function() {
  setupEvents();
});

function setupEvents(){
  $('#attach-images').unbind();
  $('#attach-images').toggle(function(){
    $('#new_dream-images').slideDown();
  }, function(){
    $('#new_dream-images').slideUp();
  })
}