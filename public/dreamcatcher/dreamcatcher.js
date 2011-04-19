steal.plugins(
	'steal/coffee',
	'jquery/controller',			// a widget factory
	//'jquery/controller/subscribe',	// subscribe to OpenAjax.hub
	'jquery/view/ejs',				// client side templates
	'jquery/controller/view',		// lookup views with the controller's name
	'jquery/model',					// Ajax wrappers
	'jquery/dom/fixture',			// simulated Ajax requests
	'jquery/dom/form_params')		// form data helper
	
	//.css('cookbook')	// loads styles

	.resources()					// 3rd party script's (like jQueryUI), in resources folder
	.then(function() {
		steal.coffee(
			'models/appearancepanel',
			'controllers/appearancepanel_controller'
		);
	})
	.views();