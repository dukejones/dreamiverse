/* DO NOT MODIFY. This file was compiled Thu, 09 Jun 2011 00:09:08 GMT from
 * /Users/carboes/Sites/dreamcatcher/app/coffee/jmvc/dreamcatcher.coffee
 */

(function() {
  var controllers, helpers, models, page;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  steal.plugins('steal/coffee', 'jquery/controller', 'jquery/controller/subscribe', 'jquery/controller/history', 'jquery/view/ejs', 'jquery/controller/view', 'jquery/model', 'jquery/dom/fixture', 'jquery/dom/form_params').resources('ui/jquery.ui.core', 'ui/jquery.ui.widget', 'ui/jquery.ui.mouse', 'ui/jquery.ui.position', 'ui/jquery.ui.selectmenu', 'ui/jquery.ui.draggable', 'ui/jquery.ui.droppable', 'jquery.tooltip.js', 'jquery-lightbox-0.5', 'jquery.tooltip.js', 'jquery.timeago', 'jquery.exists', 'jquery.cookie', 'jquery.dateFormat-1.0', 'jquery.query-2.1.7', 'jquery.livequery', 'fileuploader', 'jquery.linkify', 'videolink', 'dream.plugs').then(__bind(function() {
    helpers('cookie', 'upload', 'ui');
    models('user', 'image');
    controllers('application', 'users/meta_menu', 'users/settings');
    switch (page()) {
      case 'images':
        return controllers({
          package: 'images',
          classes: ['image_bank', 'browser', 'slideshow', 'dropbox', 'search_options', 'manager', 'manager_uploader', 'manager_meta', 'manager_selector']
        });
      case 'admin':
        models('admin');
        return controllers({
          package: 'admin',
          classes: ['admin']
        });
      default:
        models('entry', 'book', 'stream', 'comment');
        return controllers({
          package: 'entries',
          classes: ['entries', 'new', 'books', 'stream', 'comments', 'show']
        }, {
          package: 'users',
          classes: ['appearance', 'bedsheets']
        });
    }
  }, this)).views();
  controllers = function() {
    var arg, className, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = arguments.length; _i < _len; _i++) {
      arg = arguments[_i];
      _results.push((function() {
        var _j, _len2, _ref, _results2;
        if (arg.package != null) {
          _ref = arg.classes;
          _results2 = [];
          for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
            className = _ref[_j];
            _results2.push(steal.coffee("controllers/" + arg.package + "/" + className + "_controller"));
          }
          return _results2;
        } else {
          return steal.coffee("controllers/" + arg + "_controller");
        }
      })());
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
