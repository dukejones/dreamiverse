# stretch textarea size - originally from alpha site for text area expansion
# dr. J's first coffee script!
window.fitToContent = (id, maxHeight) ->
  text = if id and id.style then id else document.getElementById(id)
  return 0 if not text
  adjustedHeight = text.clientHeight
  if not maxHeight or maxHeight > adjustedHeight
    adjustedHeight = Math.max(text.scrollHeight, adjustedHeight)
    adjustedHeight = Math.min(maxHeight, adjustedHeight) if maxHeight
    $(text).animate(height: (adjustedHeight + 80) + "px") if adjustedHeight > text.clientHeight

