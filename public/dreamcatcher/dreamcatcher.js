/* DO NOT MODIFY. This file was compiled Thu, 16 Jun 2011 21:16:38 GMT from
 * /Users/phong/Sites/dreamcatcher/public/dreamcatcher/coffee/dreamcatcher.coffee
 */

(function() {
  var controllers, helpers, models, page, resources;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  steal.plugins('steal/coffee', 'jquery/controller', 'jquery/controller/subscribe', 'jquery/controller/history', 'jquery/view/ejs', 'jquery/controller/view', 'jquery/model', 'jquery/dom/fixture', 'jquery/dom/form_params').resources('ui/jquery.ui.core', 'ui/jquery.ui.widget', 'ui/jquery.ui.mouse', 'ui/jquery.ui.position', 'ui/jquery.ui.selectmenu', 'ui/jquery.ui.draggable', 'ui/jquery.ui.droppable', 'jquery.tooltip.js', 'jquery-lightbox-0.5', 'jquery.tooltip.js', 'jquery.timeago', 'jquery.exists', 'jquery.cookie', 'jquery.dateFormat-1.0', 'jquery.query-2.1.7', 'jquery.livequery', 'jquery.placeholder', 'fileuploader', 'jquery.linkify', 'videolink', 'dream.plugs').then(__bind(function() {
    helpers('cookie', 'ui');
    models('user', 'image', 'tag', 'comment');
    controllers('application', {
      module: 'common',
      classes: ['upload', 'tags', 'comments']
    }, {
      module: 'users',
      classes: ['meta_menu']
    });
    switch (page()) {
      case 'images':
        return controllers({
          module: 'images',
          classes: ['images', 'browser', 'slideshow', 'dropbox', 'search_options', 'manager']
        });
      case 'admin':
        resources('google.charts');
        models('admin', 'chart');
        return controllers('admin', 'charts');
      default:
        models('entry', 'book', 'stream');
        controllers({
          module: 'entries',
          classes: ['dream_field', 'dream_stream', 'newedit_entry', 'books', 'show_entry']
        });
        return controllers({
          module: 'users',
          classes: ['context_panel', 'appearance_panel']
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
        if (arg.module != null) {
          _ref = arg.classes;
          _results2 = [];
          for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
            className = _ref[_j];
            _results2.push(steal.coffee("controllers/" + arg.module + "/" + className + "_controller"));
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
  resources = function() {
    var arg, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = arguments.length; _i < _len; _i++) {
      arg = arguments[_i];
      _results.push(steal.coffee("resources/" + arg));
    }
    return _results;
  };
  page = function() {
    return window.location.href.split('/').pop();
  };
}).call(this);
