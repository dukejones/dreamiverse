$(document).ready(function(){
  initGeo();
})

var geoFetching = false;
var locationSuccess = false;

function initGeo(){
  $('.addLocation').unbind();
  $('.addLocation').click(function(){
    if($('.entryLocation').css('display') == 'none'){
      $(this).addClass('selected');
      $('.entryLocation').slideDown()
      
      if(!geoFetching){
        geoFetching = true;
        getGeo();
      }
    } else {
      $('.entryLocation').slideUp();
    }
  });
  
  $('.entryLocation .locationHeader').click(function(){
    $('.entryLocation').slideUp();
  })
  
  $('.entryLocation .cancelLocation').unbind();
  $('.entryLocation .cancelLocation').click(function(){
    $('.addLocation').removeClass('selected');
    $('.entryLocation').slideUp();
    
    $('.entryLocation .city .input').val('');
    $('.entryLocation .state .input').val('');
    $('.entryLocation .country .input').val('');
  });
  
  $('#locationList').change(function(){
    if($(this).find('option:selected').attr('value') == 'New location'){
      if(locationSuccess){
        $('.entryLocation .expander .name .input').val('');
      }
      
      $('.entryLocation .expander').slideDown();
      $('.entryLocation').animate({height: 104}, "fast");
    } else {
      $('.entryLocation .expander').slideUp();
      $('.entryLocation').animate({height: 35}, "fast");
    }
  })
}

/* LOCATION DATA */
var getGeo = function(){
  if(navigator.geolocation){
    // Check for cookie "geoaccept" if found, do nothing
    // if not found, display the geoHeader & set cookie
    // so user doesnt see it after this time
    /*if(window.getCookie("geoaccept") == null){
      showGeoHeader();
    }*/
    showGeoHeader();
    
    navigator.geolocation.getCurrentPosition(geoSuccess, geoError, {timeout:5000});
    
    // Inject the google geo api
    //window.injectJs('http://maps.google.com/maps/api/js?sensor=false')
  } else {
    alert('This browser does not support geolocation')
  }
}

function showGeoHeader(){
  // Only show header for Firefox Browser
  if(window.BrowserDetect.browser == "Firefox" || window.BrowserDetect.browser == "Chrome"){
    var newElement = '<div id="geoHeader"><p>Allow your browser to check for your location.</p><div class="geoArrow"></div></div>';
    $('body').prepend(newElement);
  
    $('#geoHeader').animate({top: 0}, 1000);
  
    $('#geoHeader').click(function(){
      //window.setCookie("geoaccept", 1, 365)
      $(this).remove()
    })
  }
}

function geoError(error){
  $('.entryLocation .data').slideDown()
  $('.entryLocation .finding').remove();
}

function geoSuccess(position) {

  /*// Dont think we can use this, only works in FF
  var city = position.address.city;
  var region = position.address.region;
  var country = position.address.country;
  
  $('.entryLocation .data').slideDown()
  $('.entryLocation .finding').remove();
  
  // Set geo data
  $('.entryLocation .city .input').val(city);
  $('.entryLocation .state .input').val(region);
  $('.entryLocation .country .input').val(country);*/
  
  
  var lat = position.coords.latitude;
  var lng = position.coords.longitude;
  
  // Slide up geoHeader & set cookie to not show geoHeader again
  $('#geoHeader').slideUp();
  //window.setCookie("geoaccept", 1, 365)
  
  getAddress(lat, lng);
}

function getAddress(_lat, _lng){
  // Get location data from google
  var lat = parseFloat(_lat);
  var lng = parseFloat(_lng);
  
  // Set hidden input fields
  $('#location_attributes_longitude').val(lng)
  $('#location_attributes_latitude').val(lat)
  
  var url = 'http://maps.googleapis.com/maps/api/geocode/json?latlng=' + _lat + ',' + _lng + '&sensor=true';
  console.log(url)
  
  // NEW WAY (still under construction ;D)
  /*$.getJSON('http://maps.googleapis.com/maps/api/geocode/json?latlng=45.5854466,-122.695003&sensor=true', function(data) {
    console.log(data)
  });*/

  
  // OLD WAY
  var latlng = new google.maps.LatLng(lat, lng);
  
  var geocoder = new google.maps.Geocoder();
  geocoder.geocode( {'latLng': latlng }, function(data, status){
    console.log(data)
    // Remove finding your location option
    $('.entryLocation .data').slideDown()
    $('.entryLocation .finding').remove();
    
    var country = data[0].address_components[6].short_name.toLowerCase();
    
    // Set geo data
    $('.entryLocation .city .input').val(data[0].address_components[2].long_name);
    $('.entryLocation .state .input').val(data[0].address_components[5].short_name);
    $('.entryLocation .country .input').val(country);
  })
}