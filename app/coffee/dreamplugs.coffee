
$(document).ready ->
  setupDreamplugs()
  
# init
window.setupDreamplugs = ->
  # Setup slide triggers to work
  $('.trigger.slide').click( (event) ->
    $newTargetSlide = $(event.currentTarget).parent().find('.target.slide')
    
    if $newTargetSlide.css('display') is 'none'
      $newTargetSlide.slideDown()
    else
      $newTargetSlide.slideUp()
  )
  
  $('.trigger.showhide').click( (event) ->
    $newTargetShowHide = $(event.currentTarget).parent().find('.target.showhide')
    
    if $newTargetShowHide.css('display') is 'none'
      $newTargetShowHide.show()
    else
      $newTargetShowHide.hide()
  )
  
  # Setup fade triggers to work
  $('.trigger.fade').click( (event) ->
    $newTargetFade = $(event.currentTarget).parent().find('.target.fade')
    
    if $newTargetFade.css('display') is 'none'
      $newTargetFade.fadeIn()
    else
      $newTargetFade.fadeOut()
  )
  
  # Setup fade w/ bodyclick triggers to work
  $('.trigger.fadeclick').click( (event) ->
    $newTargetFade = $(event.currentTarget).parent().find('.target.fadeclick')
    
    if $newTargetFade.css('display') is 'none'
      # Create bodyclick
      bodyClick = '<div id="bodyClick" style="z-index: 1100; cursor: pointer; width: 100%; height: 100%; position: fixed; top: 0; left: 0;" class=""></div>'
      $('body').prepend(bodyClick)
    
      $('html, body').animate({scrollTop:0}, 'slow');
    
      $('#bodyClick').click( (event) =>
        $newTargetFade.hide()
        $('#bodyClick').remove()
      )
      
      $newTargetFade.fadeIn()
    else
      $newTargetFade.fadeOut()
      $('body').remove()
  )
  
  # Setup toggle handler
  $('.trigger.toggle').click( (event) ->
    $newTargetToggle = $(event.currentTarget).parent().parent().find('.target.toggle')
    $oldTargetToggle = $(event.currentTarget).parent()
    
    $oldTargetToggle.hide()
    $newTargetToggle.show()
  )