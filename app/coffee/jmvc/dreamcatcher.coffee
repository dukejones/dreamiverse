steal.plugins(

  'steal/coffee',
	'jquery/controller' # a widget factory
	'jquery/controller/subscribe' #subscribe to OpenAjax.hub
	'jquery/controller/history'
	'jquery/view/ejs' # client side templates
	'jquery/controller/view' # lookup views with the controller's name
	'jquery/model' # Ajax wrappers
	'jquery/dom/fixture' # simulated Ajax requests
	'jquery/dom/form_params' # form data helper
	
).resources(	  

	'ui/jquery.ui.core'
	'ui/jquery.ui.widget'
	'ui/jquery.ui.mouse'
  'ui/jquery.ui.position'
  'ui/jquery.ui.selectmenu'
  'ui/jquery.ui.draggable'
	'ui/jquery.ui.droppable'	
			
	'jquery.tooltip.js'
  'jquery-lightbox-0.5'
  'jquery.tooltip.js'
  'jquery.timeago'
	'jquery.exists'
	'jquery.cookie'
	'jquery.dateFormat-1.0'
	'jquery.query-2.1.7'
	'jquery.livequery'
	
	'fileuploader'
	'jquery.linkify'
	'jquery.videolink'
	'dream.plugs' 
	
).then( =>  

  helpers 'cookie', 'upload', 'ui'
  models 'user', 'image'
  controllers 'application', 'users/meta_menu', 'users/settings'
  switch page()
    when 'images'
      controllers {
        group: 'images'
        elements: ['image_bank', 'browser', 'slideshow', 'dropbox', 'search_options', 'manager']
      }
    when 'stream'
      models 'stream', 'entry', 'comment', 'bedsheet'
      controllers {
        group: 'entries'
        elements: ['stream', 'entries', 'comments']
      }
    when 'carboes'
      models 'entry', 'book', 'comment', 'bedsheet'
      controllers {
        group: 'entries'
        elements: ['entries', 'new', 'books', 'comments']
      }, {
        group: 'users'
        elements: ['appearance', 'bedsheets']
      }
      
).views()


#- helper functions

controllers = ->
  for arg in arguments
    if arg.group?
      group = arg.group
      steal.coffee "controllers/#{group}/#{el}_controller" for el in arg.elements
    else
      steal.coffee "controllers/#{arg}_controller" for arg in arguments
    
models = ->
  steal.coffee "models/#{arg}" for arg in arguments
  
helpers = ->
  steal.coffee "classes/#{arg}_helper" for arg in arguments
    
page = ->
  window.location.href.split('/').pop()
