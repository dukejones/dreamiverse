notice = function(message) {
  $('.notice p').text(message);
  $('.alert').hide();
  $('#globalAlert,.notice').show();
  setTimeout(hideGlobalAlert, 5000);
}

alert = function(message) {
  $('.alert p').text(message);
  $('.notice').hide();
  $('#globalAlert,.alert').show();
  setTimeout(hideGlobalAlert, 5000);
}

hideGlobalAlert = function() {
  $('#globalAlert').fadeOut('500');
}