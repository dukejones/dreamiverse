notice = function(message) {
  $('.notice p').text(message);
  $('.alert').hide();
  $('#globalAlert, .notice').show();
  setTimeout(hideGlobalAlert,3000);
}


alert = function(message) {
  $('.alert p').text(message);
  $('.notice').hide();
  $('#globalAlert, .alert').show();
  setTimeout(hideGlobalAlert,3000);
}


hideGlobalAlert = function() {
  $('#globalAlert').fadeOut('500');
}


fitToContent = function(id, maxHeight) {
  text = (id && id.style) ? id : document.getElementById(id);
  if (!text)
    return 0 
  adjustedHeight = text.clientHeight;
  if (!maxHeight || maxHeight > adjustedHeight) {
    adjustedHeight = Math.max(text.scrollHeight, adjustedHeight);
    if (maxHeight)
      adjustedHeight = Math.min(maxHeight, adjustedHeight);
    if (adjustedHeight > text.clientHeight)
      $(text).animate( { height: (adjustedHeight + 80) + "px" } );
  }
}
    
