
$(document).ready ->
  setupDreamplugs()
  
# init
window.setupDreamplugs = ->
  # Setup slide triggers to work
  $('.trigger.slide').click( (event) ->
    newTarget = $(event.currentTarget).parent().find('.target')
    
    if newTarget.css('display') is 'none'
      newTarget.slideDown()
    else
      newTarget.slideUp()
  )