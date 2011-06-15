steal.plugins(

  'steal/coffee'
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
	'videolink'
	'dream.plugs'
	
).then( =>  

  # common jmvc files
  helpers 'cookie', 'ui'
  models 'user', 'image', 'tag', 'comment'
  controllers 'application', {
    module: 'common'
    classes: ['upload', 'tags', 'comments']
  }, {
    module: 'users'
    classes: ['meta_menu']#, 'settings_panel']
  }
  
  # page-specific jmvc files
  switch page()
  
    when 'images'
      controllers { 
        module: 'images'
        classes: ['images', 'browser', 'slideshow', 'dropbox', 'search_options', 'manager']
      }
      
    when 'admin'
      models 'admin'
      controllers {
        module: 'admin'
        classes: ['admin']
      }
    
    else
      models 'entry', 'book', 'stream'
      controllers {
        module: 'entries'
        classes: ['dream_field', 'dream_stream', 'newedit_entry', 'books', 'show_entry']
      }
      controllers {
        module: 'users'
        classes: ['context_panel', 'appearance_panel']
      }
      
).views()


#- helper functions (used within steal 'then')
controllers = ->
  for arg in arguments
    if arg.module?
      for className in arg.classes
        steal.coffee "controllers/#{arg.module}/#{className}_controller" 
    else
      steal.coffee "controllers/#{arg}_controller"
    
models = ->
  steal.coffee "models/#{arg}" for arg in arguments
  
helpers = ->
  steal.coffee "classes/#{arg}_helper" for arg in arguments
    
scotts = ->
  steal.coffee "scott/#{arg}" for arg in arguments
    
page = ->
  window.location.href.split('/').pop()
