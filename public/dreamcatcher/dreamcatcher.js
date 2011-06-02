steal.plugins(
	'steal/coffee',
	'jquery/controller',			// a widget factory
	'jquery/controller/subscribe',	// subscribe to OpenAjax.hub
	'jquery/controller/history',
	'jquery/view/ejs',				// client side templates
	'jquery/controller/view',	// lookup views with the controller's name
	'jquery/model',					  // Ajax wrappers
	'jquery/dom/fixture',			// simulated Ajax requests
	'jquery/dom/form_params'
	)	// form data helper
	.resources(
	  'ui/jquery.ui.core',
		'ui/jquery.ui.widget',
		'ui/jquery.ui.mouse',
    'ui/jquery.ui.position',
    'ui/jquery.ui.selectmenu',
    'ui/jquery.ui.draggable',
		'ui/jquery.ui.droppable',		
		
		'jquery.tooltip.js',
	  'jquery-lightbox-0.5',
	  'jquery.tooltip.js',
	  'jquery.timeago',
		'jquery.exists',

		'jquery.cookie',
		'jquery.dateFormat-1.0',
		'jquery.query-2.1.7',
		'jquery.livequery',
		
		'fileuploader',
		
		'jquery.linkify',
		'jquery.videolink',
		'dream.plugs'
    
  )              // 3rd party script's (like jQueryUI), in resources folder
  .then(function() {
    page = window.location.href.split('/').pop();
    imageBank = (page == 'images');
    stream = (page == "stream")
    //TODO: StealJS fix: don't forget to contribute!
    steal.coffee(
      'classes/cookie_helper',
      'classes/upload_helper',
      'classes/ui_helper',
      'models/settings',
      'models/image',
      'controllers/application_controller',
      'controllers/meta_menu_controller',
      'controllers/settings_controller'
    );
    if (imageBank) {
      steal.coffee(
        'controllers/image_bank/image_bank_controller',
			  'controllers/image_bank/browser_controller',
			  'controllers/image_bank/slideshow_controller',
			  'controllers/image_bank/dropbox_controller',
			  'controllers/image_bank/search_options_controller',	
			  'controllers/image_bank/manager_controller',
			  'controllers/image_bank/manager_uploader_controller',
			  'controllers/image_bank/manager_selector_controller',
			  'controllers/image_bank/manager_meta_controller'
			);
    } else if (stream) {
      steal.coffee(
        'models/stream',
        'models/comment',
        'controllers/stream_controller',
        'controllers/comments_controller'
      );
    } else {
      steal.coffee(
        'models/appearance',
        'models/bedsheet',
        'models/user',
        'models/entry',
        'models/user',
        'models/book',
        'controllers/appearance_controller',
        'controllers/bedsheets_controller',
        'controllers/entry_field/entries_controller',
        'controllers/entry_field/new_controller',
        'controllers/entry_field/books_controller'
      );
    }
  })
  .views();