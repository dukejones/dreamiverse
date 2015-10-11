$(document).ready(function(){
  //setupHeaderButtons();
})

function closeAllHeaders(){
  $('#appearancePanel').fadeOut();
  $('#settingsPanel').fadeOut();
}

function setupHeaderButtons(){
  $('#metaMenu .appearance').click(function(){
    if($('#appearancePanel').css('display') == 'none'){
      closeAllHeaders();
      $('#appearancePanel').show();
      // Create clickable div to close when not clicking on element
      var newElement = '<div id="bodyClick" style="z-index: 1100; cursor: pointer; width: 100%; height: 100%; position: fixed; top: 0; left: 0;" class=""></div>';
    
      $('body').prepend(newElement);
    
      // Scroll to top of page
      $('html, body').animate({scrollTop:0}, 'slow');
    
      $('#bodyClick').click(function(event){
        // Hide Settings
        $('#appearancePanel').fadeOut();
        $('#bodyClick').fadeOut().remove();
      })
    
    } else {
      $('#appearancePanel').fadeOut();
      $('#bodyClick').fadeOut().remove();
    }
  })
  
  $('#metaMenu .settings').click(function(){
    if($('#settingsPanel').css('display') == 'none'){
      closeAllHeaders();
      $('#settingsPanel').show();
      // Create clickable div to close when not clicking on element
      var newElement = '<div id="bodyClick" style="z-index: 1100; cursor: pointer; width: 100%; height: 100%; position: fixed; top: 0; left: 0;" class=""></div>';
    
      $('body').prepend(newElement);
    
      // Scroll to top of page
      $('html, body').animate({scrollTop:0}, 'slow');
    
      $('#bodyClick').click(function(event){
        // Hide Settings
        $('#settingsPanel').fadeOut();
        $('#bodyClick').fadeOut().remove();
      })
    
    } else {
      $('#settingsPanel').fadeOut();
      $('#bodyClick').fadeOut().remove();
    }
  })
}

