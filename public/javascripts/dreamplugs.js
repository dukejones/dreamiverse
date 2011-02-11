/* DO NOT MODIFY. This file was compiled Wed, 02 Feb 2011 18:09:45 GMT from
 * /Users/scotthedstrom/Sites/dreamcatcher/app/coffee/dreamplugs.coffee
 */

(function() {
  /*
  Start Expander
  scott@dreamcatcher.net

  Example Use:
  $('#myObj').expander({params});
  // See defaults belowfor params to pass

  */  $.fn.expander = function(options) {
    var $this, defaults, opts;
    $this = $(this);
    defaults = {
      speed: '',
      toClick: '.expand-click',
      toExpand: '.expander',
      type: 'slide'
    };
    opts = $.extend(defaults, options);
    $this.find(opts.toExpand).hide();
    $this.find(opts.toClick).css('cursor', 'pointer');
    return $this.find(opts.toClick).click(function(event) {
      if ($this.find(opts.toExpand).css("display" === "none")) {
        switch (opts.type) {
          case "slide":
            return $this.find(opts.toExpand).slideDown(opts.speed);
          case "fade":
            return $this.find(opts.toExpand).fadeIn(opts.speed);
        }
      } else {
        switch (opts.type) {
          case "slide":
            return $this.find(opts.toExpand).slideUp(opts.speed);
          case "fade":
            return $this.find(opts.toExpand).fadeOut(opts.speed);
        }
      }
    });
  };
  /*
  Start dcHover
  scott@dreamcatcher.net

  Example Use:
  $('#myObj').dcHover({hoverClass: "myHoverState"});

  */
  $.fn.dcHover = function(options) {
    var $this, defaults, hoverOff, hoverOn, opts;
    $this = $(this);
    defaults = {
      hoverClass: 'hoverState'
    };
    opts = $.extend(defaults, options);
    $this.find(opts.toClick).css('cursor', 'pointer');
    /* Create functions for hover */
    hoverOn = function(event) {
      return $this.addClass(opts.hoverClass);
    };
    hoverOff = function(event) {
      return $this.removeClass(opts.hoverClass);
    };
    return $this.hover(hoverOn, hoverOff);
  };
  /*
  Start dcFadeHover
  scott@dreamcatcher.net

  Example Use:
  $('#myObj').dcFadeHover({color: "#000"});

  */
  $.fn.dcFadeHover = function(options) {
    var $this, defaults, hoverOff, hoverOn, opts;
    $this = $(this);
    defaults = {
      color: '#000'
    };
    opts = $.extend(defaults, options);
    $this.find(opts.toClick).css('cursor', 'pointer');
    /* Create functions for hover */
    hoverOn = function(event) {
      return $this.stop().animate({
        shadow: '0 0 30px ' + opts.color + ' inset'
      });
    };
    hoverOff = function(event) {
      return $this.stop().animate({
        shadow: '0 0 0px ' + opts.color + ' inset'
      });
    };
    return $this.hover(hoverOn, hoverOff);
  };
}).call(this);
