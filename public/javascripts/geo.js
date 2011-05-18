$(document).ready(function(){
  //initGeo();
})

var geoFetching = false;
var locationSuccess = false;

function initGeo(){
  $('#entry_location').unbind();
  $('#entry_location').click(function(){
    if($('.entryLocation').css('display') == 'none'){
      $(this).addClass('selected');
      //$('.entryLocation').slideDown()
      slideToggle('.entryLocation', true)
      
      if(!geoFetching && !$('.entryLocation').data('id')){
        geoFetching = true;
        getGeo();
      } else {
        $('.finding').hide()
        $('.entryLocation').find('.data').show()
      }
    } else {
      //$('.entryLocation').slideUp();
      slideToggle('.entryLocation', false)
    }
  });
  
  $('.entryLocation .locationHeader').click(function(){
    //$('.entryLocation').slideUp();
    slideToggle('.entryLocation', false)
  })
  
  $('.entryLocation .cancelLocation').unbind();
  $('.entryLocation .cancelLocation').click(function(){
    $('#entry_location').removeClass('selected');
    //$('.entryLocation').slideUp();
    slideToggle('.entryLocation', false)
    
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
    } else {
      $('.entryLocation .expander').slideUp();
    }
  })
}

function slideToggle(el, bShow){
  var $el = $(el), height = $el.data("originalHeight"), visible = $el.is(":visible");
  
  // if the bShow isn't present, get the current visibility and reverse it
  if( arguments.length == 1 ) bShow = !visible;
  
  // if the current visiblilty is the same as the requested state, cancel
  if( bShow == visible ) return false;
  
  // get the original height
  if( !height ){
    // get original height
    height = $el.show().height();
    // update the height
    $el.data("originalHeight", height);
    // if the element was hidden, hide it again
    if( !visible ) $el.hide().css({height: 0});
  }

  // expand the knowledge (instead of slideDown/Up, use custom animation which applies fix)
  if( bShow ){
    $el.show().animate({height: height}, {duration: 250});
  } else {
    $el.animate({height: 0}, {duration: 250, complete:function (){
        $el.hide();
      }
    });
  }
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
  $('#location_latitude').val(lat);
  $('#location_longitude').val(lng);
  
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

  
  // Get the address for the lng/lat info
  var latlng = new google.maps.LatLng(lat, lng);
  
  var geocoder = new google.maps.Geocoder();
  geocoder.geocode( {'latLng': latlng }, function(data, status){
    // Remove finding your location option
    $('.entryLocation .data').slideDown()
    $('.entryLocation .finding').remove();
    
    // parse geo data
    var country;
    var province;
    var city;
    
    $.each(data[0].address_components, function(i, datum) {
      if (datum.types[0] == 'country') {
        country = datum.long_name;
      }
      if (datum.types[0] == 'administrative_area_level_1') {
        province = datum.short_name;
      }
      if (datum.types[0] == 'administrative_area_level_2') {
        city = datum.long_name;
      }
    });
    
    // Set geo data
    $('.entryLocation .city .input').val(city);
    $('.entryLocation .state .input').val(province);
    $('.entryLocation .country .input').val(country);
  })
}