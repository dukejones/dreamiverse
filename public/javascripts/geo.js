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
    showGeoHeader();
    navigator.geolocation.getCurrentPosition(geoSuccess, geoError, {timeout:5000});
    
    // Inject the google geo api
    // window.injectJs('http://maps.google.com/maps/api/js?sensor=false')
  } else {
    alert('This browser does not support geolocation')
  }
}

function showGeoHeader(){
  var newElement = '<div id="geoHeader"><p>Allow your browser to check for your location.</p><div class="geoArrow"></div></div>';
  $('body').prepend(newElement);
  
  $('#geoHeader').animate({top: 0}, 1000);
  
  $('#geoHeader').click(function(){
    $(this).remove()
  })
}

function geoError(error){
  //alert("geolocation error : " + error.code + ' / ' + error.message);
  $('.entryLocation .data').slideDown()
  $('.entryLocation .finding').remove();
}

function geoSuccess(position) {
  var lat = position.coords.latitude;
  var lng = position.coords.longitude;
  $('#geoHeader').slideUp();
  getAddress(lat, lng);
}

function getAddress(_lat, _lng){
  // Get location data from google
  var lat = parseFloat(_lat);
  var lng = parseFloat(_lng);
  
  // Set hidden input fields
  $('#location_attributes_longitude').val(lng)
  $('#location_attributes_latitude').val(lat)
  
  var latlng = new google.maps.LatLng(lat, lng);
  
  var geocoder = new google.maps.Geocoder();
  geocoder.geocode( {'latLng': latlng }, function(data, status){
    // Remove finding your location option
    $('.entryLocation .data').slideDown()
    $('.entryLocation .finding').remove();
    
    // Add new location
    /*var newElement = '<option value="' + data[0].address_components[2].long_name + ', ' + data[0].address_components[5].short_name + '">' + data[0].address_components[2].long_name + ', ' + data[0].address_components[5].short_name + '</option>';
    $('#locationList').prepend(newElement);
    $('#locationList').val(data[0].address_components[2].long_name + ', ' + data[0].address_components[5].short_name)*/
    
    var country = data[0].address_components[6].short_name.toLowerCase();
    
    // Set geo data
    $('.entryLocation .city .input').val(data[0].address_components[2].long_name);
    $('.entryLocation .state .input').val(data[0].address_components[5].short_name);
    $('.entryLocation .country .input').val(country);
  })
}