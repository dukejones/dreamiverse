$(document).ready(function() {
  setupTagStream();
})

function setupTagStream(){
  // Tag input clear on focus
  $('#tagInput').focus(function(){
    if($(this).val() == $(this).attr('title')){
      clearMePrevious = $(this).val();
      $(this).val('');
    }
  });
  
  // Tag input put text back on blur if empty
  $('#tagInput').blur(function(){
    if($(this).val() == ""){
      $(this).val($(this).attr('title'));
    }
  });
}