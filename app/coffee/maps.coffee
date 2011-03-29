# displaying maps on entries
$(document).ready ->
  initShowEntryMap()
  
initShowEntryMap = ->
  if $('#entryLocationMap').data('lng')? and $('#entryLocationMap').data('lat')?
    lat = $('#entryLocationMap').data('lat')
    lng = $('#entryLocationMap').data('lng')
    latlng = new google.maps.LatLng(lng, lat)
    
    myOptions =
      zoom: 18
      center: latlng
      mapTypeId: google.maps.MapTypeId.HYBRID

    map = new google.maps.Map(document.getElementById("entryLocationMap"), myOptions)
    map.setTilt(45)
    
    markerOptions =
      position: latlng
      map: map
      title:"Dreamcatcher"

    marker = new google.maps.Marker(markerOptions)
    log('SETTING CLICK EVENT')
    $('.postLocation').css('cursor', 'pointer')
    $('.postLocation').click( ->
      log $('#entryLocationMap').css('top')
      if $('#entryLocationMap').css('top') isnt '-1000px'
        $('#entryLocationMap').css('top', '-1000px')
      else
        $('#entryLocationMap').css('top', '50px')
        $('html, body').animate({scrollTop:0}, 'slow');
    )
  # Need to finish this up. if the lng/lat is not available, use the 
  # city/state information
  ###else
    geocoder = new google.maps.Geocoder()
    addressObject =
      address: 'Portland, OR'
    geocoder.geocode( addressObject, (results, status) ->
      if status is google.maps.GeocoderStatus.OK
        map.setCenter(results[0].geometry.location)
        #var marker = new google.maps.Marker({
        #    map: map, 
        #    position: results[0].geometry.location
      else
        alert("Geocode was not successful for the following reason: " + status);

      