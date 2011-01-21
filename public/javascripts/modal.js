/* DO NOT MODIFY. This file was compiled Fri, 21 Jan 2011 04:17:41 GMT from
 * /Users/iotus/Sites/dreamcatcher/app/coffee/modal.coffee
 */

(function() {
  typeof dc != "undefined" && dc !== null ? dc : dc = {};
  dc.modal = function() {
    return $("<div>You should use Chrome Frame. Our site doesn't work on jank browsers like IE 6.</div>").dialog({
      modal: true,
      dialogClass: 'light O O-shine',
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
