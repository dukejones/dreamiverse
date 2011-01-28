$(document).ready(function(){
  setupHeaderButtons();
})

function setupHeaderButtons(){
  $('#settings_menu .appearance').toggle(function(){
    $('#appearancePanel').fadeIn();
  }, function(){
    $('#appearancePanel').fadeOut();
  })
}