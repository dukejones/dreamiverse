$(document).ready(function(){
  setupHeaderButtons();
})

function setupHeaderButtons(){
  $('#settings_menu .appearance').click(function(){
    if($('#appearanceWrap').css('display') == 'none'){
      $('#appearanceWrap').fadeIn();
    } else {
      $('#appearanceWrap').fadeOut();
    }
  })
}