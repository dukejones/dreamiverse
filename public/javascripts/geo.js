$(document).ready(function(){
  initGeo();
})

var geoFetching = false;
var locationSuccess = false;

function initGeo(){
  $('.addLocation').unbind();
  $('.addLocation').click(function(){
    if($('#locationPanel').css('display') == 'none'){
      $(this).addClass('selected');
      
      //$('#locationPanel').slideDown();
      // Fix for the min-height bug
      
      $('#locationPanel').height(0);
      $('#locationPanel').css('display', 'block');
      
      if($('#locationPanel .expander').css('display') == 'none'){
        $('#locationPanel').animate({height: 35}, "fast");
      } else {
        $('#locationPanel').animate({height: 100}, "fast");
      }
      
      
      
      if(!geoFetching){
        geoFetching = true;
        getGeo();
      }
    } else {
      $('#locationPanel').slideUp();
    }
  });
  
  $('#locationPanel .locationHeader').click(function(){
    $('#locationPanel').slideUp();
  })
  
  $('#locationPanel .delete').unbind();
  $('#locationPanel .delete').click(function(){
    $('.addLocation').removeClass('selected');
    $('#locationPanel, #locationPanel .expander').slideUp();
    $('#locationList').val('No location');
  });
  
  $('#locationList').change(function(){
    if($(this).find('option:selected').attr('value') == 'New location'){
      if(locationSuccess){
        $('#locationPanel .expander .name .input').val('');
      }
      
      $('#locationPanel .expander').slideDown();
      $('#locationPanel').animate({height: 100}, "fast");
    } else {
      $('#locationPanel .expander').slideUp();
      $('#locationPanel').animate({height: 35}, "fast");
    }
  })
}

/* LOCATION DATA */
var getGeo = function(){
  if(navigator.geolocation){
    navigator.geolocation.getCurrentPosition(geoSuccess, geoError, {timeout:15000});
  } else {
    alert('This browser does not support geolocation')
  }
}

function geoError(error){
  alert("geolocation error : " + error.code + ' / ' + error.message);
  $('#locationPanel .spinner-small').fadeOut();
  
  $('#locationList').val('No location');
  $('#locationList .finding').remove();
}

function geoSuccess(position) {
  var lat = position.coords.latitude;
  var lng = position.coords.longitude;
  getAddress(lat, lng);
  
  // Turn on new location button
  setupGeo();
}

function getAddress(_lat, _lng){
  // Get location data from google
  var lat = parseFloat(_lat);
  var lng = parseFloat(_lng);
  var latlng = new google.maps.LatLng(lat, lng);
  
  var geocoder = new google.maps.Geocoder();
  geocoder.geocode( {'latLng': latlng }, function(data, status){
    
    // Remove finding your location option
    $('#locationList .finding').remove();
    
    // Add new location
    var newElement = '<option value="' + data[0].address_components[2].long_name + ', ' + data[0].address_components[5].short_name + '">' + data[0].address_components[2].long_name + ', ' + data[0].address_components[5].short_name + '</option>';
    $('#locationList').prepend(newElement);
    $('#locationList').val(data[0].address_components[2].long_name + ', ' + data[0].address_components[5].short_name)
    
    // Set geo data
    $('#locationPanel .city .input').val(data[0].address_components[2].long_name);
    $('#locationPanel .state .input').val(data[0].address_components[5].short_name);
    $('#locationPanel .country input').val(data[0].address_components[6].long_name);
    
    // Remove Spinner
    $('#locationPanel .spinner-small').fadeOut();
  })
}

function parseme(results){
  alert("results :: " + results);
}