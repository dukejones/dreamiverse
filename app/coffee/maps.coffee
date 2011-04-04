# displaying maps on entries
#$(document).ready ->
#  initShowEntryMap()

initShowEntryMap = ->
  if $('#entryLocationMap').data('lng') isnt '' and $('#entryLocationMap').data('lat') isnt ''
    lat = $('#entryLocationMap').data('lat')
    lng = $('#entryLocationMap').data('lng')
    
    mapLocation = lat + ',' + lng
    mapElement = '<img src="http://maps.google.com/maps/api/staticmap?center=' + mapLocation + '&zoom=6&size=662x200&maptype=hybrid&markers=color:blue&sensor=false" style="width: 662px;" />'
    $('#entryLocationMap').html(mapElement)
    
    $('.postLocation').css('cursor', 'pointer')
    $('.postLocation').click( ->
      if $('#entryLocationMap').css('display') is 'none'
        $('#entryLocationMap').fadeIn(250)
        $('html, body').animate({scrollTop:0}, 'slow');
      else
        $('#entryLocationMap').fadeOut(250)        
    )
  else
    city = $('#entryLocationMap').data('city')
    province = $('#entryLocationMap').data('province')
    
    mapLocation = city + ',' + province
    
    mapElement = '<img src="http://maps.google.com/maps/api/staticmap?center=' + mapLocation + '&zoom=6&size=662x200&maptype=hybrid&markers=color:blue&sensor=false" style="width: 662px;" />'
    $('#entryLocationMap').html(mapElement)
    
    $('.postLocation').css('cursor', 'pointer')
    $('.postLocation').click( ->
      if $('#entryLocationMap').css('display') is 'none'
        $('#entryLocationMap').fadeIn(250)
        $('html, body').animate({scrollTop:0}, 'slow');
      else
        $('#entryLocationMap').fadeOut(250)        
    )