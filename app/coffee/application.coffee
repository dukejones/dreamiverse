window.log = (msg)-> console.log(msg) if console?

require({baseUrl: "/javascripts"},
  ['pubsub', 'rails', 'jquery.hoverIntent.minified', 'jquery-ui.min', "jquery.placeholder"],
  -> 
    $('input[placeholder],textarea[placeholder]').placeholder()
)

# js/chat  
