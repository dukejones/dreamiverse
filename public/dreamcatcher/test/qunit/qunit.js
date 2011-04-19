steal
  .plugins("steal/coffee","funcunit/qunit", "cookbook")
  .then(function(){
    steal.coffee("cookbook_test");
  });