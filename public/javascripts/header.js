$(document).ready(function(){
  setupHeaderButtons();
})

function setupHeaderButtons(){
  $('#metaMenu .appearance').click(function(){
    if($('#appearanceWrap').css('display') == 'none'){
      $('#appearanceWrap').fadeIn();
    } else {
      $('#appearanceWrap').fadeOut();
    }
  })
}