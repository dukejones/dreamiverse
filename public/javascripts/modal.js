/* DO NOT MODIFY. This file was compiled Mon, 31 Jan 2011 07:38:54 GMT from
 * /Users/iotus/Sites/dreamcatcher/app/coffee/modal.coffee
 */

(function() {
  typeof dc != "undefined" && dc !== null ? dc : dc = {};
  dc.modal = function() {
    return $("<div>Your web browser is incompatible with Dreamcatcher.net. Please install Google's Chrome Frame to fix the issue.</div>").dialog({
      title: 'Incompbatible browser',
      modal: true,
      width: 358,
      dialogClass: 'static-glow-40',
      closeText: '',
      buttons: {
        "Ok": function() {
          console.log('ok');
          return $(this).dialog("close");
        },
        "Cancel": function() {
          console.log('no way');
          return $(this).dialog("close");
        }
      }
    });
  };
}).call(this);
