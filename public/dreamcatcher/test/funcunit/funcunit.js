steal
 .plugins("steal/coffee","funcunit")
 .then(function() {
   steal.coffee(
     "dreamcatcher_test",
     //"metamenu_controller_test",
     //"settings_controller_test",
     "appearance_controller_test"//,
     //"bedsheet_controller_test",
     //"comment_controller_test"
   );
 });