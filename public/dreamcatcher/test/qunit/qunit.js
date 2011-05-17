steal
  .plugins("steal/coffee","funcunit/qunit", "dreamcatcher")
  .then(function(){
    steal.coffee(
      "dreamcatcher_test",
      //"appearance_test",
      //"bedsheet_test"
      //"comment_test",
      "settings_test"
    );
  });