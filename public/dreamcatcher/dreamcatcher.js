steal.plugins(
	'steal/coffee',
	'jquery/controller',			// a widget factory
	'jquery/controller/subscribe',	// subscribe to OpenAjax.hub
	'jquery/view/ejs',				// client side templates
	'jquery/controller/view',	// lookup views with the controller's name
	'jquery/model',					  // Ajax wrappers
	'jquery/dom/fixture',			// simulated Ajax requests
	'jquery/dom/form_params')	// form data helper
	//.css('cookbook')	      // loads styles
	.resources()					    // 3rd party script's (like jQueryUI), in resources folder
	.then(function() {
    //StealJS fix: don't forget to contribute!
		steal.coffee(
			'models/settings',
			'models/appearance',
			'models/bedsheets',
			'controllers/metamenu_controller',
			'controllers/settings_controller',
			'controllers/appearance_controller',
			'controllers/bedsheets_controller'
		);
	})
	.views();