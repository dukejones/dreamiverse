// Setup Vars
var autoCompleteExpanded = false;
var textTyped = false;
var locationExpanded = false;
var sharingExpanded = false;

$(document).ready(function() {
  setupTagStream();
})

function setupTagStream(){
  // Hide nodes
  $('#autoComplete .results').hide();
  
  // Setup auto-complete
  $('#tagInput').keypress(function(event){
    // Change me, just makes the results show after
    // more than 3 chars have been typed
    var numberOfChars = $('#tagInput').val().split('').length;
    if(numberOfChars > 2){
      // Hide searching
      $('#searching-temp').hide();
      
      if(!autoCompleteExpanded){
        // Expand auto-complete dropdown
        autoCompleteExpanded = true;
      
        // Setup click event on .results
        $('#autoComplete .results').click(function(){
          // add tag to display
          selectTag($(this));
        });
      
        $('#autoComplete').slideDown('fast');
      
      
      }
      
      // Display results
      $('#autoComplete .results').fadeIn('fast');
    }
  });
  
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
  
  // Sharing & Location Expander
  $('#sharingExpand').toggle(function(){
    $('#share').slideDown();
  }, function(){
    $('#share').slideUp();
  })
}

function selectTag($this){
  // Hide autoComplete tag selector
  $('#autoComplete').fadeOut('fast');
  
  // switch to info input view
  setInputType('info');
}

function setInputType(type){
  switch(type){
    case "tag":
      
      break;
    
    case "info":
      $('#tagInput').val('What were they doing?');
      $('#tagInput').css('width', '300px');
      $('#tagInput').css('margin', '4px 0 4px 170px');
      
      $('#tagInput').focus(function(){
        if($(this).val() == 'What were they doing?'){
          $(this).val('');
        }
      })
      
      // Show tag node
      $('.tagNode').fadeIn();
      break;
  }
}