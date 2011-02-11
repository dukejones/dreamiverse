
$(document).ready ->
  setupDreamplugs()
  
# init
window.setupDreamplugs = ->
  # Setup slide triggers to work
  $('.trigger.slide').click( (event) ->
    $newTarget = $(event.currentTarget).parent().find('.target.slide')
    
    if $newTarget.css('display') is 'none'
      $newTarget.slideDown()
    else
      $newTarget.slideUp()
  )
  
  # Setup fade triggers to work
  $('.trigger.fade').click( (event) ->
    $newTarget = $(event.currentTarget).parent().find('.target.fade')
    
    if $newTarget.css('display') is 'none'
      $newTarget.fadeIn()
    else
      $newTarget.fadeOut()
  )
  
  # Setup toggle handler
  $('.trigger.toggle').click( (event) ->
    $newTarget = $(event.currentTarget).parent().parent().find('.target.toggle')
    $oldTarget = $(event.currentTarget).parent()
    
    $oldTarget.hide()
    $newTarget.show()
  )