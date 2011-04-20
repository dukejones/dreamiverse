steal
  .plugins("steal/coffee","funcunit/qunit", "dreamcatcher")
  .then(function(){
    steal.coffee(
      "dreamcatcher_test",
      "bedsheet_test"
    );
  });