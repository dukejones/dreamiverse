window.log = (msg)-> console.log(msg) if console?

window.requireConfig = {
  paths:
    'js' : '..'
}

require(requireConfig,
  ['js/pubsub', 'js/rails', 'js/jquery.hoverIntent.minified', 'js/jquery-ui.min', "js/jquery.placeholder"],
  -> 
    $('input[placeholder],textarea[placeholder]').placeholder()
)

# js/chat  
