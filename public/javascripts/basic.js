// JavaScript Document

// HEADER INIT CODE basic/templates/header.html init code
$(document).ready(function(){
  // setupInput Clearer
  $('.input').focus(function(){
    alert('focus')
    if($(this).val() == $(this).attr('title')){
      $(this).attr('title')= $(this).val();
      $(this).val('');
    }
  });

  // Tag input put text back on blur if empty
  $('.input').blur(function(){
    if($(this).val() == ""){
      $(this).val($(this).attr('title'));
    }
  });
})

function MM_jumpMenu(targ,selObj,restore){ //v3.0
  eval(targ+".location=\'"+selObj.options[selObj.selectedIndex].value+"\'"); 
  if (restore) selObj.selectedIndex=0;
}
// END HEADER INIT CODE basic/templates/header.html init code



// FM
// Make sure the "FM" namespace object exists
if (typeof FM != 'object') {
    FM = new Object();
}

/**
 * Checks a given class attribute for the presence of a given class
 *
 * @author  Dan Delaney     http://fluidmind.org/
 * @param   element         DOM Element object (or element ID) to remove the class from
 * @param   nameOfClass     The name of the CSS class to check for
 */
FM.checkForClass = function(element, nameOfClass) {
    if (typeof element == 'string') { element = document.getElementById(element); }
  
    if (element == null) { 
      return false; 
    } else if (element.className == '') {
        return false;
    } else {
        return new RegExp('\\b' + nameOfClass + '\\b').test(element.className);
    }
}


/**
 * Adds a class to an element's class attribute
 *
 * @author  Dan Delaney     http://fluidmind.org/
 * @param   element         DOM Element object (or element ID) to add the class to
 * @param   nameOfClass     Class name to add
 * @see     checkForClass
 */
FM.addClass = function(element, nameOfClass) {
    if (typeof element == 'string') { element = document.getElementById(element); }

    if (!FM.checkForClass(element, nameOfClass)) {
        element.className += (element.className ? ' ' : '') + nameOfClass;
        return true;
    } else {
        return false;
    }
}


/**
 * Removes a class from an element's class attribute
 *
 * @author  Dan Delaney     http://fluidmind.org/
 * @param   element         DOM Element object (or element ID) to remove the class from
 * @param   nameOfClass     Class name to remove
 * @see     checkForClass
 */
FM.removeClass = function(element, nameOfClass) {
    if (typeof element == 'string') { element = document.getElementById(element); }

    if (FM.checkForClass(element, nameOfClass)) {
        element.className = element.className.replace(
            (element.className.indexOf(' ' + nameOfClass) >= 0 ? ' ' + nameOfClass : nameOfClass),
            '');
        return true;
    } else {
        return false;
    }
}


/**
 * Replaces a class with another if the class is present
 *
 * @author  Dan Delaney     http://fluidmind.org/
 * @param   element         DOM Element object (or element ID) to remove the class from
 * @param   class1          Class name to replace
 * @param   class2          Class name to replace it with
 * @see     checkForClass
 * @see     addClass
 * @see     removeClass
 */
FM.replaceClass = function(element, class1, class2) {
    if (typeof element == 'string') { element = document.getElementById(element); }

    if (FM.checkForClass(element, class1)) {
        FM.removeClass(element, class1);
        FM.addClass(element, class2);
        return true;
    } else {
        return false;
    }
}


/**
 * Toggles the specified class on and off
 *
 * @author  Dan Delaney     http://fluidmind.org/
 * @param   element         DOM Element object (or element ID) to toggle the class of
 * @param   nameOfClass     Class name to toggle
 * @see     checkForclass
 * @see     addClass
 * @see     removeClass
 */
FM.toggleClass = function(element, nameOfClass) {
    if (typeof element == 'string') { element = document.getElementById(element); }

    if (FM.checkForClass(element, nameOfClass)) {
        FM.removeClass(element, nameOfClass);
    } else {
        FM.addClass(element, nameOfClass);
    }

    return true;
}

// END FM

// THEME SELECTOR
window.onload = function() {
  if (document.getElementById('userId') != null) {
    if (document.getElementById('userId').value >= '0') {
      if(document.getElementById('themeSelectorWrapper')){
// VARIABLES
    var getBodyBackground = document.getElementById('bodyBackground');
    var getColorValue = document.getElementById('colorValue');
    var sheetSelector = document.getElementById('bedsheetSelector');
//    var bedsheetPanelButton = document.getElementById('bedsheetPanelButton');
//    var bedsheetPanelClose = document.getElementById('bedsheetPanelClose');
    var previewSheetsButton = document.getElementById('previewSheetsButton');
    var setSheetsButton = document.getElementById('setSheetsButton');
    var cancelSheetsButton = document.getElementById('cancelSheetsButton');
    var ubiquityButton = document.getElementById('ubiquityButton');
    var getubiquityBox = document.getElementById('ubiquityBox2');
    var sheetPreview = document.getElementById('bedsheet-preview');
    
    
    if(document.getElementById('bedsheetPositioning')){
      var getScrollRadio = document.forms['scrollForm'].elements['scroll'];
      var getScrollForm = document.forms['scrollForm'];
    }
    
    
    // GET DEFAULTS FROM IN-PAGE FORMS
    var userName = document.getElementById('userName').value;
    var pageType = document.getElementById('pageType').value;
    var userId = document.getElementById('userId').value;
    var themeColor = document.getElementById('themeColor').value;
    var themeScroll = document.getElementById('themeScroll').value;
    var themeBedsheetPath = document.getElementById('themeBedsheetPath').value;
    var themeUbiquity = document.getElementById('themeUbiquity').value;
    //END VARIABLES

//  APPLY DEFAULT
    function applyDefaultTheme() {
      getColorValue.setAttribute('value', themeColor );              // sets the hidden colorValue holder to have the default value selected
      sheetSelector.value = themeBedsheetPath;                  // makes the current bedsheet SELECTED by default in the bedhseet selector
      sheetPreview.setAttribute('style', 'background: url(' + "/basic/inc/bedsheets/collection/" + themeBedsheetPath + '-128.jpg)');  // applies default bedsheet to preview pane
      for (var i = 0, len = getScrollForm.length; i < len; ++i) {          // set default FIXED or SCROLL in quicksettings
        if (getScrollForm[i].value == themeScroll) {
          getScrollForm[i].checked = true;
        };
      };
      // set default UBIQUITY setting - checks the box automatically from the variable sent from the back-end
      if (themeUbiquity == '1') {      // if the default value is UBIQUITY
        getubiquityBox.checked = true;        // check the ubiquityBox2
        getubiquityBox.setAttribute('value', '1' );              // and set its VALUE to 1
//        FM.addClass('ubiquityCheckbox','checked');
      } else {
        getubiquityBox.checked = false;        // otherwise make sure it is unchecked and leave value as 0
        getubiquityBox.setAttribute('value', '0' );              // and set its VALUE to 0
//        FM.removeClass('ubiquityCheckbox','checked');
      };
    };
    window.onload = applyDefaultTheme();
// END APPLY DEFAULT

//  QUICKSETTINGS PANEL FUNCTIONS
    //  COLOR SELECTOR
    if (document.getElementById('sunButton') != null) {
      document.getElementById('sunButton').onclick = function() {    // when the value of the Bedsheet Selector is changed, run the following function
        Rainbow('light');
        getColorValue.setAttribute('value', 'light' );
      };
    };
    if (document.getElementById('moonButton') != null) {
      document.getElementById('moonButton').onclick = function() {    // when the value of the Bedsheet Selector is changed, run the following function
        Rainbow('dark');
        getColorValue.setAttribute('value', 'dark' );
      };
    };

    // BEDSHEET SELECTOR
    // EXPANDER
//    if (bedsheetPanelButton != null) {
//      bedsheetPanelButton.onclick = function () {
//        FM.toggleClass('bedsheetPanel','hidden');
//        FM.toggleClass('bedsheetPanelButton','hidden');
//      };
//    };
//    if (bedsheetPanelClose != null) {
//      bedsheetPanelClose.onclick = function () {
//        FM.toggleClass('bedsheetPanel','hidden');
//        FM.toggleClass('bedsheetPanelButton','hidden');  
//      };
//    };
    // SELECTOR
    if (sheetSelector != null) {
      sheetSelector.onchange = function() {    // when the value of the Bedsheet Selector is changed, run the following function
        sheetPreview.setAttribute('style', '' );  // clear preview pane background
        sheetPreview.setAttribute('style', 'background:url(' + "/basic/inc/bedsheets/collection/" + sheetSelector.value + '-128.jpg)' );    // apply corresponding 128 pixel background image
      };
      // this part enables ENTER and SPACE key on the fly previewing
      sheetSelector.onkeypress = function(x) {    // when any key is pressed run this function
        if (!x) x = window.event;          // de-jankalizes IE to work with ENTER key
        if (x.keyCode == 13 || x.which == 13 || x.keyCode == 32 || x.which == 32) {   // determines if the ENTER 13 or SPACE 32 key was pressed    KNOWN ISSUE with google chrome - ENTER will reload the page
          setBodyBackground();          // sets the background
        };
      };
    };
  
    // FIXED or SCROLL
    function getScrollValue() {
      r = getScrollRadio;
      for(var x = 0; x < r.length; x++) {      // scans through the options
        if(r[x].checked) {            // if one of them is checked
          scrollValue = r[x].value;      // define scrollValue to be the value of the selected option
        };
      };
    };

    //UBIQUITY CONTROLS
    if (ubiquityButton != null) {
//      ubiquityButton.onmouseover = function () {
//        FM.addClass('ubiquityCheckbox','checkbox-hover');
//      };
//      ubiquityButton.onmouseout = function () {
//        FM.removeClass('ubiquityCheckbox','checkbox-hover');
//      };
      ubiquityButton.onclick = function() {
        r = getubiquityBox;              // sets variable r temporarily for the scope of this function
        if(r.checked) {                // if the checkbox is checked
          r.checked = false;
          r.setAttribute('value', '0' );      // set the VALUE attribute of the checkbox to 1
//          FM.removeClass('ubiquityCheckbox','checked');
        } else {                  //  if it is NOT checked when the user clicks on it
          r.checked = true;
          r.setAttribute('value', '1');      // set the VALUE attribute to 0
//          FM.addClass('ubiquityCheckbox','checked');
        };
      };
    };
  
    // Bedsheet PREVIEW Button
    if (previewSheetsButton != null) {
      previewSheetsButton.onclick = function() {
        setBodyBackground();
        sheetSelector.focus();          //returns focus back to the SELECT list, expected UI behavior
      };
    };

    // SET BUTTON
    if (setSheetsButton != null) {
      setSheetsButton.onclick = function() {
        getScrollValue();
        if (pageType == 'modify') {        // if the user is on the modify page, rewrite ONLY the hidden input values
          if (document.getElementById('themeColor')) {
            document.getElementById('themeColor').setAttribute('value', getColorValue.value );
          };
          if (document.getElementById('themeScroll')) {
            document.getElementById('themeScroll').setAttribute('value', scrollValue );
          };
          if (document.getElementById('themeBedsheetPath')) {
            document.getElementById('themeBedsheetPath').setAttribute('value', sheetSelector.value );
          };
          if (document.getElementById('themeUbiquity')) {
            document.getElementById('themeUbiquity').setAttribute('value', getubiquityBox.value );
          };
          if (document.getElementById('themeUbiquity').value == '1') {        // allows for setting ubiquity on modify or edit dream mode
            document.getElementById('bedsheetSaver').setAttribute('src', '/' + userName + '/update-page-theme/?userId=' + userId + '&pageType=' + pageType + '&color=' + getColorValue.value + '&scroll=' + scrollValue + '&bedsheetPath=' + sheetSelector.value + '&ubiquity=' + getubiquityBox.value);
          };
          } else {
            if ((pageType == 'profile') || (pageType == 'user-home-matrix')) {    // but if theyre on the profile or dream matrix, write the iframe
              document.getElementById('bedsheetSaver').setAttribute('src', '/' + userName + '/update-page-theme/?userId=' + userId + '&pageType=' + pageType + '&color=' + getColorValue.value + '&scroll=' + scrollValue + '&bedsheetPath=' + sheetSelector.value + '&ubiquity=' + getubiquityBox.value);
              if (document.getElementById('themeColor')) {
                document.getElementById('themeColor').setAttribute('value', getColorValue.value );
              };
              if (document.getElementById('themeScroll')) {
                document.getElementById('themeScroll').setAttribute('value', scrollValue );
              };
              if (document.getElementById('themeBedsheetPath')) {
                document.getElementById('themeBedsheetPath').setAttribute('value', sheetSelector.value );
              };
              if (document.getElementById('themeUbiquity')) {
                document.getElementById('themeUbiquity').setAttribute('value', getubiquityBox.value );
              };
            };
          };
        setBodyBackground();
        toggleAppearance();
      };
    };

    // CANCEL BUTTONgi
    if (cancelSheetsButton != null) {
      cancelSheetsButton.onclick = function () {
        Rainbow(document.getElementById('themeColor').value);
        getColorValue.setAttribute('value', document.getElementById('themeColor').value );              // sets the hidden colorValue holder to have the default value selected
        sheetSelector.value = document.getElementById('themeBedsheetPath').value;                  // makes the current bedsheet SELECTED by default in the bedhseet selector
        sheetPreview.setAttribute('style', 'background: url(' + "/basic/inc/bedsheets/collection/" + document.getElementById('themeBedsheetPath').value + '-128.jpg)');  // applies default bedsheet to preview pane
        for (var i = 0, len = getScrollForm.length; i < len; ++i) {          // set default FIXED or SCROLL in quicksettings
          if (getScrollForm[i].value == document.getElementById('themeScroll').value) {
            getScrollForm[i].checked = true;
          };
        };
        // set default UBIQUITY setting - checks the box automatically from the variable sent from the back-end
        if (document.getElementById('themeUbiquity').value == '1') {      // if the default value is UBIQUITY
          getubiquityBox.checked = true;        // check the ubiquityBox2
          getubiquityBox.setAttribute('value', '1' );              // and set its VALUE to 1
          FM.addClass('ubiquityCheckbox','checked');
        } else {
          getubiquityBox.checked = false;        // otherwise make sure it is unchecked and leave value as 0
          getubiquityBox.setAttribute('value', '0' );              // and set its VALUE to 0
          FM.removeClass('ubiquityCheckbox','checked');
        };
        setBodyBackground();
        toggleAppearance();
      };
    };

// SET HI-RES BEDSHEET
    function setBodyBackground() {
      getScrollValue();                // refreshes value for scrollValue to check if it has been changed from Default
      if (getColorValue.value == 'light') {      // sets bg color as light gray on theme switch
        getBodyBackground.setAttribute('style', 'background: url(' + "/basic/inc/bedsheets/collection/" + sheetSelector.value + '-hi.jpg) ' + scrollValue + '#ccc');  // sets background color light
      };
      if (getColorValue.value == 'dark') {      // sets bg color as dark gray on theme switch
        getBodyBackground.setAttribute('style', 'background: url(' + "/basic/inc/bedsheets/collection/" + sheetSelector.value + '-hi.jpg) ' + scrollValue + '#202020');  // sets background color light
      };
    };

    } else {      // if the user is NOT logged in,
      return;      // do nothing
    };


  } else {      // if the form element is NOT on the page,
    return;      // do nothing
  };
} else {
  return;
};
  
};
// END THEME SELECTOR


// RAINBOW COLOR SELECTOR
var colorObjects = new Array( );

function Rainbow(color){
  var currentColor = document.getElementById('colorValue').value;    // grabs the curent color value from the themeSelector panel hidden input colorValue, defines currentColor
  for (var i=0; i < colorObjects.length; i++) {  // scans through Color Objects
    var ID = colorObjects[i];          // generates the ID for each colorObject
    FM.replaceClass ( ID , currentColor, color); // Replaces currentColor classes with the new Color classes
  };
  currentColor = color;              // sets Current Color
};
// END RAINBOW COLOR SELECTOR


/**
 * Creates a partially-transparent 100% width & height div, and sets its click function to the callback which you pass in.
 * After being clicked it removes itself from the DOM.
*/
function createModal(callback) {
  // Create clickable iFrame to close when not clicking on element
  var newElement = '<div id="bodyClick" style="z-index: 1000; cursor: pointer; width: 100%; height: 100%; position: fixed; top: 0; left: 0;" class=""></div>';
  $('body').prepend(newElement);
  if (callback) {
    $('#bodyClick').click(function() {
      callback.call(this);
      $('#bodyClick').fadeOut().remove();
    });
  } // else this modal is not closable.
}


// OPEN AND CLOSE THEME PANEL
var settingsExpanded = false;
//500000
function toggleAppearance() {
  if(!settingsExpanded){
    // Show Settings
    settingsExpanded = true;
    $('#appearancePanel').fadeIn('fast');
    $('#appearanceArrow').fadeIn('fast');
    
    createModal(function() {
      // Hide Settings
      settingsExpanded = false;
      $('#appearancePanel').fadeOut('fast');
      $('#appearanceArrow').fadeOut('fast');
    });
  } else {
    // Hide Settings
    settingsExpanded = false;
    $('#appearancePanel').fadeOut('fast');
    $('#settingsArrow').fadeOut('fast');
    $('#appearanceArrow').fadeOut().remove();
  }
};

function toggleThemePanel(){
  //FM.toggleClass('themeShortcut','sub_menu-item-on');
  
  if(!settingsExpanded){
    // Show Settings
    settingsExpanded = true;
    $('#themeSelector').slideDown('fast');
    $('#settingsPanelWrapper').fadeIn('fast');
    $('#settingsArrow').fadeIn('fast');
    
    // Create clickable iFrame to close when not clicking on element
    var newElement = '<div id="bodyClick" style="z-index: 1000; cursor: pointer; width: 100%; height: 100%; position: fixed; top: 0; left: 0;" class=""></div>';
    
    $('body').prepend(newElement);
    
    // Scroll to top of page
    $('html, body').animate({scrollTop:0}, 'slow');
    
    $('#bodyClick').click(function(event){
      // Hide Settings
      settingsExpanded = false;
      $('#settingsPanelWrapper').fadeOut('fast');
      $('#settingsArrow').fadeOut('fast');
      $('#bodyClick').fadeOut().remove();
    })
    
  } else {
    // Hide Settings
    settingsExpanded = false;
    $('#settingsPanelWrapper').fadeOut('fast');
    $('#settingsArrow').fadeOut('fast');
    $('#bodyClick').fadeOut().remove();
  }
}


// JAVASCRIPT Link for DIVs and stuff
function Link(URL){ window.location = URL; };


// SET FONT ENTRYBODY FONT SIZE
var  fontSizes = new Array("font-15", "font-17","font-21"); // define the three sizes of fonts - small, med, large
var  fontSizesButtonID = new Array("fontSizeA", "fontSizeB","fontSizeC"); // define the respective IDs of the font-size buttons
                
function setFontSizeButton(){ // sets the size of the font button to reflect the actual size of the font in the entryBody
for (i=0; i < fontSizes.length; i++){ // cycle through the number of fontSizes
                
  var classConfirm = FM.checkForClass('entryBodyBox',fontSizes[i]); // check to see if it\'s been applied to the entryBody

  if (classConfirm != false){ // if it HAS been applied
    FM.addClass( fontSizesButtonID[i], 'O-contrast' ); // make the button also reflect it\'s condition
    } else {

      if ( FM.checkForClass(fontSizesButtonID[i],'O-contrast') != false ){
        FM.removeClass( fontSizesButtonID[i], 'O-contrast' );
      }
    }
  }
}

function setFontSize( targetId, className ){ // sets the font size of the entryBody
  for( i=0; i<fontSizes.length; i++ ){ // cycle through font sizes
    if ( FM.checkForClass(targetId, fontSizes[i]) != false ){ // if a font size is applied, remove it
      FM.replaceClass( targetId, fontSizes[i],className ); // remove al font classes
    }
  }
  setFontSizeButton(); // set the button
  // FitToContent(targetId, document.documentElement.clientHeight)
}


var fontList = new Array("arial","calibri","verdana","monospace","comic","georgia","garamond","book","times");
function setFont(idd,newFontName){ // changes the font in the IDD to the fontName coorosponding to CSS class
  var newFontClassName = "font-"+ newFontName;
  for(i=0; i<fontList.length; i++){ // cycle through the font list
    var oldFontClassName = "font-"+fontList[i];
    if ( FM.checkForClass(idd, oldFontClassName) != false ){ // if a font size is applied, remove it
      FM.replaceClass( idd, oldFontClassName, newFontClassName ); // replace old font with new one
    }
  }
}
// END SET FONT ENTRYBODY FONT SIZE


// FIT TO CONTENT
function FitToContent(id, maxHeight)
{
  var text = id && id.style ? id : document.getElementById(id);
  if ( !text )
    return;
  var adjustedHeight = text.clientHeight;
  if ( !maxHeight || maxHeight > adjustedHeight  )
  {
    adjustedHeight = Math.max(text.scrollHeight, adjustedHeight);
    if ( maxHeight )
      adjustedHeight = Math.min(maxHeight, adjustedHeight);
    if ( adjustedHeight > text.clientHeight )
      text.style.height = adjustedHeight + 200 + "px";
  }
}
// END FIT TO CONTENT

// GOOGLE ANALYTICS
var _gaq = _gaq || [];
_gaq.push(['_setAccount', 'UA-600135-8']);
_gaq.push(['_setDomainName', '.dreamcatcher.net']);
_gaq.push(['_trackPageview']);

(function() {
  var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
  ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
  var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
})();
// END GOOGLE ANALYTICS

//  KNOWN ISSUES
//    google chrome ENTER key issue - pressing ENTER in bedsheetSelector refreshes the whole page