$(document).ready(function(){
  $('#submitButton, #details, #bugType').hide()
  $('textarea#detailsForm').keyup(function() {
    return fitToContent(this, 0);
  }); 
})

$('#type').focus();
window.onload = function() {
  var feedbackType = document.getElementById('type');
  var bugOptions = document.getElementById('bugOptions');
  feedbackType.onchange = function () {
    if (feedbackType.value === "bug") {
      $('#bugType').slideDown('fast');
      $('#details').slideUp('fast');
      $('#submitButton').fadeOut('fast');
      document.getElementById('bugOptions').focus();
    } else if (feedbackType.value === "idea") {
      $('#details').slideDown('fast');
      $('#submitButton').fadeIn('fast');
      $('#bugType').slideUp('fast');
      document.getElementById('detailsForm').focus();
    } else if (feedbackType.value === "none") {
      $('#bugType').slideUp('fast');
      $('#details').slideUp('fast');
      $('#submitButton').fadeOut('fast');
    };
  };
  bugOptions.onchange = function () {
    if (bugOptions.value === "data not saving" || bugOptions.value === "browser crash" || bugOptions.value === "confusing feature" || bugOptions.value === "other") {
      $('#details').slideDown('fast');
      $('#submitButton').fadeIn('fast');
      document.getElementById('detailsForm').focus();
    } else if (bugOptions.value === "none") {
      $('#details').slideUp('fast');
      $('#submitButton').fadeOut('fast');
    };
  };
};



