/* DO NOT MODIFY. This file was compiled Mon, 06 Jun 2011 19:01:21 GMT from
 * /Users/carboes/Sites/dreamcatcher/app/coffee/jmvc/dreamcatcher.coffee
 */

(function() {
  var controllers, helpers, models, page;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  steal.plugins('steal/coffee', 'jquery/controller', 'jquery/controller/subscribe', 'jquery/controller/history', 'jquery/view/ejs', 'jquery/controller/view', 'jquery/model', 'jquery/dom/fixture', 'jquery/dom/form_params').resources('ui/jquery.ui.core', 'ui/jquery.ui.widget', 'ui/jquery.ui.mouse', 'ui/jquery.ui.position', 'ui/jquery.ui.selectmenu', 'ui/jquery.ui.draggable', 'ui/jquery.ui.droppable', 'jquery.tooltip.js', 'jquery-lightbox-0.5', 'jquery.tooltip.js', 'jquery.timeago', 'jquery.exists', 'jquery.cookie', 'jquery.dateFormat-1.0', 'jquery.query-2.1.7', 'jquery.livequery', 'fileuploader', 'jquery.linkify', 'jquery.videolink', 'dream.plugs').then(__bind(function() {
    helpers('cookie', 'upload', 'ui');
    models('user', 'image');
    controllers('application', 'users/meta_menu', 'users/settings');
    switch (page()) {
      case 'images':
        return controllers({
          group: 'images',
          elements: ['image_bank', 'browser', 'slideshow', 'dropbox', 'search_options', 'manager']
        });
      case 'stream':
        models('stream', 'entry', 'comment');
        return controllers({
          group: 'entries',
          elements: ['stream', 'entries', 'comments']
        });
      case 'carboes':
        models('entry', 'book', 'comment');
        return controllers({
          group: 'entries',
          elements: ['entries', 'new', 'books', 'comments']
        }, {
          group: 'users',
          elements: ['appearance', 'bedsheets']
        });
    }
  }, this)).views();
  controllers = function() {
    var arg, el, group, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = arguments.length; _i < _len; _i++) {
      arg = arguments[_i];
      _results.push((function() {
        var _j, _k, _len2, _len3, _ref, _results2, _results3;
        if (arg.group != null) {
          group = arg.group;
          _ref = arg.elements;
          _results2 = [];
          for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
            el = _ref[_j];
            _results2.push(steal.coffee("controllers/" + group + "/" + el + "_controller"));
          }
          return _results2;
        } else {
          _results3 = [];
          for (_k = 0, _len3 = arguments.length; _k < _len3; _k++) {
            arg = arguments[_k];
            _results3.push(steal.coffee("controllers/" + arg + "_controller"));
          }
          return _results3;
        }
      }).apply(this, arguments));
    }
    return _results;
  };
  models = function() {
    var arg, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = arguments.length; _i < _len; _i++) {
      arg = arguments[_i];
      _results.push(steal.coffee("models/" + arg));
    }
    return _results;
  };
  helpers = function() {
    var arg, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = arguments.length; _i < _len; _i++) {
      arg = arguments[_i];
      _results.push(steal.coffee("classes/" + arg + "_helper"));
    }
    return _results;
  };
  page = function() {
    return window.location.href.split('/').pop();
  };
}).call(this);
