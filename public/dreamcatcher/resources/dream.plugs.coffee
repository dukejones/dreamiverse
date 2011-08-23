notice = (message) ->
  $('.notice p').text message
  $('.alert').hide()
  $('#globalAlert, .notice').show()
  setTimeout =>
    hideGlobalAlert()
  , 5000


alert = (message) ->
  $('.alert p').text message
  $('.notice').hide()
  $('#globalAlert, .alert').show()
  setTimeout =>
    hideGlobalAlert()
  , 5000


hideGlobalAlert = ->
  $('#globalAlert').fadeOut('500')

# stretch textarea size - originally from alpha site for text area expansion
# dr. J's first coffee script!
fitToContent = (id, maxHeight) ->
  text = if id and id.style then id else document.getElementById(id)
  return 0 if not text
  adjustedHeight = text.clientHeight
  if not maxHeight or maxHeight > adjustedHeight
    adjustedHeight = Math.max(text.scrollHeight, adjustedHeight)
    adjustedHeight = Math.min(maxHeight, adjustedHeight) if maxHeight
    $(text).animate(height: (adjustedHeight + 80) + "px") if adjustedHeight > text.clientHeight
