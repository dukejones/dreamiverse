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
	  
	# jQuery plug-ins
	
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

  #commonly-used helpers, models and controllers
  
  helpers 'cookie', 'upload', 'ui'
  models 'user', 'image'
  controllers 'application', 'users/meta_menu', 'users/settings'
  
  switch page()
  
    #load specific models and controllers dependant on page
  
    when 'images'
    
      controllers {
        package: 'images'
        classes: ['image_bank', 'browser', 'slideshow', 'dropbox', 'search_options', 'manager', 'manager_uploader', 'manager_meta', 'manager_selector']
      }
      
    when 'stream'
    
      models 'stream', 'entry', 'comment', 'bedsheet'
      
      controllers {
        package: 'entries'
        classes: ['stream', 'entries', 'comments']
      }
      
    else # e.g. page = username / 'carboes'
    
      models 'entry', 'book', 'comment', 'appearance', 'bedsheet'
      
      controllers {
        package: 'entries'
        classes: ['entries', 'new', 'books', 'comments']
      }, {
        package: 'users'
        classes: ['appearance', 'bedsheets']
      }
      
).views()


#- helper functions

controllers = ->
  for arg in arguments
    if arg.package?
      steal.coffee "controllers/#{arg.package}/#{className}_controller" for className in arg.classes
    else
      steal.coffee "controllers/#{arg}_controller"
    
models = ->
  steal.coffee "models/#{arg}" for arg in arguments
  
helpers = ->
  steal.coffee "classes/#{arg}_helper" for arg in arguments
    
page = ->
  window.location.href.split('/').pop()
