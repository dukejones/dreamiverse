// Create the top-level object you will access this thru
// we will most likely already have one of these for you 
// to use.

$dc = {};

// Create the element's you will be accessing & using
// this is almost like a CLASS, include all functionality
// for each module in its own 'CLASS' for re-usability
$dc.element = (function() {
  // Define the elements you will need to interact with
  var expandButton = $('#expand-button');
  var expandElement = $('#expand-me');

  // Create the methods you will need to use as variables
  var contract = function() {
    // place all contract functionality here
    expandElement.slideUp();
  };
  
  var expand = function() {
    // Check to see if the element is expanded, and return false if so
    if (expandElement.css('display') != 'none') { return false; }

    // Place all expand functionality here
    expandElement.slideDown();
  };
  
  // the return is an Object that you can choose which
  // method to return
  return {
    contract : contract,
    expand   : expand
  }

})();