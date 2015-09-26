// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery.min
//= require fancyBox/jquery.fancybox
//= require jquery.placeholder
//= require rails
//= require swfobject
//= require json2
//= require jquery.animate-enhanced
//= require jquery.tooltip.js
//x= require jquery-lightbox-0.5
//= require jquery.timeago.js
//= require jquery.exists.js
//= require jquery.cookie.js
//= require jquery.dateFormat-1.0.js
//= require jquery.query-2.1.7.js
//= require jquery.livequery.js
//= require jquery.placeholder.js
//= require jquery.linkify.js
//= require jquery.easing.1.3.js
//= require jquery.hoverIntent.minified.js
//= require ui/jquery.ui.core.js
//= require ui/jquery.ui.widget.js
//= require ui/jquery.ui.mouse.js
//= require ui/jquery.ui.position.js
//= require ui/jquery.ui.selectmenu.js
//= require ui/jquery.ui.draggable.js
//= require ui/jquery.ui.droppable.js
//= require fileuploader.js
//= require pubsub
//
//= require_self
//= require original/loginpanel
//= require original/publicstream
//= require original/context_panel
//= require original/stream_context_panel
//= require original/showentry
//x= require original/browserdetect
//x= require original/sharing
//x= require original/fit_to_content
//x= require original/feedback
//
//x= require_tree ./original

window.log = function(msg) { if (console !== undefined) console.log(msg); }

// detect a clients utc offset time in minutes and write it to a cookie for the
// application_controller set_client_timezone method
if (!$.cookie('timezone')) {
  var current_time = new Date()
  $.cookie('timezone', current_time.getTimezoneOffset(), { path: '/', expires: 2 } );
}
