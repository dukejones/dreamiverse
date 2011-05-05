steal.plugins(
	'steal/coffee',
	'jquery/controller',			// a widget factory
	'jquery/controller/subscribe',	// subscribe to OpenAjax.hub
	'jquery/view/ejs',				// client side templates
	'jquery/controller/view',	// lookup views with the controller's name
	'jquery/model',					  // Ajax wrappers
	'jquery/dom/fixture',			// simulated Ajax requests
	'jquery/dom/form_params'
	)	// form data helper
	.resources(
	  'jquery-lightbox-0.5',
	  'jquery.timeago',
		'jquery.exists',
		'jquery.linkify',
		'jquery.videolink',
		'fileuploader',
		'jquery.cookie'
	)					    // 3rd party script's (like jQueryUI), in resources folder
	.then(function() {
    //TODO: StealJS fix: don't forget to contribute!
		steal.coffee(
			'models/settings',
			'models/appearance',
			'models/bedsheet',
			'models/comment',
			'models/image_bank',
			'controllers/application_controller',
			'controllers/metamenu_controller',
			'controllers/settings_controller',
			'controllers/appearance_controller',
			'controllers/bedsheet_controller',
			'controllers/comment_controller',
			'controllers/ib_manager_controller'
		);
	})
	.views();