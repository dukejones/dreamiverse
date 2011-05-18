steal.plugins(
  'steal/coffee',
  'jquery/controller',            // a widget factory
  'jquery/controller/subscribe',  // subscribe to OpenAjax.hub
  'jquery/view/ejs',              // client side templates
  'jquery/controller/view',       // lookup views with the controller's name
  'jquery/model',                 // Ajax wrappers
  'jquery/dom/fixture',           // simulated Ajax requests
  'jquery/dom/form_params'
  )  // form data helper
  .resources(
    'ui/jquery.ui.core',
    'ui/jquery.ui.widget',
    'ui/jquery.ui.position',
    'ui/jquery.ui.selectmenu',
    'ui/jquery.tooltip.js',
    'jquery-lightbox-0.5',
    'jquery.timeago',
    'jquery.exists',
    'jquery.linkify',
    'jquery.videolink'
  )              // 3rd party script's (like jQueryUI), in resources folder
  .then(function() {
    //TODO: StealJS fix: don't forget to contribute!
    steal.coffee(
      'classes/cookie_helper',
      'models/settings',
      'models/appearance',
      'models/bedsheet',
      'models/comment',
      'models/user',
      'controllers/application_controller',
      'controllers/meta_menu_controller',
      'controllers/settings_controller',
      'controllers/appearance_controller',
      'controllers/bedsheets_controller',
      'controllers/comments_controller'
      'controllers/entry_controller'
    );
  })
  .views();
