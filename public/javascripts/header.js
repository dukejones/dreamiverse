$(document).ready(function(){
  setupHeaderButtons();
})

function setupHeaderButtons(){
  $('#metaMenu .appearance').click(function(){
    if($('#appearanceWrap').css('display') == 'none'){
      $('#appearanceWrap').fadeIn();
      // Create clickable div to close when not clicking on element
      var newElement = '<div id="bodyClick" style="z-index: 1100; cursor: pointer; width: 100%; height: 100%; position: fixed; top: 0; left: 0;" class=""></div>';
    
      $('body').prepend(newElement);
    
      // Scroll to top of page
      $('html, body').animate({scrollTop:0}, 'slow');
    
      $('#bodyClick').click(function(event){
        // Hide Settings
        $('#appearanceWrap').fadeOut();
        $('#bodyClick').fadeOut().remove();
      })
    
    } else {
      $('#appearanceWrap').fadeOut();
      $('#bodyClick').fadeOut().remove();
    }
  })
}

