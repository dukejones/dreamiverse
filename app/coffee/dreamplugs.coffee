
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
  
  # Setup fade triggers to work
  $('.trigger.fade').click( (event) ->
    $newTargetFade = $(event.currentTarget).parent().find('.target.fade')
    
    if $newTargetFade.css('display') is 'none'
      $newTargetFade.fadeIn()
    else
      $newTargetFade.fadeOut()
  )
  
  # Setup toggle handler
  $('.trigger.toggle').click( (event) ->
    $newTargetToggle = $(event.currentTarget).parent().parent().find('.target.toggle')
    $oldTargetToggle = $(event.currentTarget).parent()
    
    $oldTargetToggle.hide()
    $newTargetToggle.show()
  )