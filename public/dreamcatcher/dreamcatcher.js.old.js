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
)	//.resources(
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
    /* TODO: dream components (separate folder)
      entries : books, stream, entry, field, comments [entry, book]
      images : image bank, browser, search, dropbox, slideshow, manager (merge back into 1) [image, user]
      
      menu : meta menu, appearance, settings [user, image, entry]
      comments (future) : entry, stream, images [comment]
      tags (future) : entry, images (or move into separate components)
      
      admin : 
    */
    page = window.location.href.split('/').pop();
    imageBank = (page == 'images');
    stream = (page == "stream")
    //TODO: StealJS fix: don't forget to contribute!
    
    
    
    steal.coffee(
      'classes/cookie_helper',
      'classes/upload_helper',
      'classes/ui_helper',
      'models/user',
      'models/image',
      'controllers/application_controller',
      'controllers/users/meta_menu_controller',
      'controllers/users/settings_controller'
    );
    if (imageBank) {
      steal.coffee(
        'controllers/images/image_bank_controller',
			  'controllers/images/browser_controller',
			  'controllers/images/slideshow_controller',
			  'controllers/images/dropbox_controller',
			  'controllers/images/search_options_controller',	
			  'controllers/images/manager_controller',
			  'controllers/images/manager_uploader_controller',
			  'controllers/images/manager_selector_controller',
			  'controllers/images/manager_meta_controller'
			);
    } else if (stream) {
      steal.coffee(
        'models/stream',
        'models/entry',  
        'controllers/entries/stream_controller',
        'controllers/entries/entries_controller'
      );
    } else {
      models('entry,book,comment')
      
      steal.coffee(
        'models/entry',
        'models/book',
        'models/comment',
        'controllers/users/appearance_controller',
        'controllers/users/bedsheets_controller',
        'controllers/entries/entries_controller',
        'controllers/entries/new_controller',
        'controllers/entries/books_controller',
        'controllers/entries/comments_controller'
      );
    }
  })
  .views();