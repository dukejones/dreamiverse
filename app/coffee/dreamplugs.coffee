###
Start Expander
scott@dreamcatcher.net

Example Use:
$('#myObj').expander({params});
// See defaults belowfor params to pass

###
$.fn.expander = (options) ->
  $this = $(this)
  
  defaults = { 
    speed: '',
    toClick: '.expand-click',
    toExpand: '.expander',
    type: 'slide'
  }
  
  opts = $.extend defaults, options
 
  $this
    .find(opts.toExpand)
    .hide()

  $this
    .find(opts.toClick)
    .css('cursor', 'pointer')
    
  $this.find(opts.toClick).click (event) -> 
   if $this.find(opts.toExpand).css "display" is "none"
      switch opts.type
        when "slide" then $this.find(opts.toExpand).slideDown opts.speed
        when "fade" then $this.find(opts.toExpand).fadeIn opts.speed
   else
      switch opts.type
        when "slide" then $this.find(opts.toExpand).slideUp opts.speed
        when "fade" then $this.find(opts.toExpand).fadeOut opts.speed

###
Start dcHover
scott@dreamcatcher.net

Example Use:
$('#myObj').dcHover({hoverClass: "myHoverState"});

###
$.fn.dcHover = (options) ->
  $this = $(this)

  defaults = { 
    hoverClass: 'hoverState'
  }

  opts = $.extend defaults, options

  $this
    .find(opts.toClick)
    .css('cursor', 'pointer')
    
  ### Create functions for hover ###
  hoverOn = (event) ->
    $this
      .addClass(opts.hoverClass)
  
  hoverOff = (event) ->
    $this
      .removeClass(opts.hoverClass)
    
  $this
    .hover hoverOn, hoverOff
      
      
###
Start dcFadeHover
scott@dreamcatcher.net

Example Use:
$('#myObj').dcFadeHover({color: "#000"});

###
$.fn.dcFadeHover = (options) ->
  $this = $(this)

  defaults = { 
    color: '#000'
  }

  opts = $.extend defaults, options

  $this
    .find(opts.toClick)
    .css('cursor', 'pointer')

  ### Create functions for hover ###
  hoverOn = (event) ->
    $this
      .stop()
      .animate({shadow: '0 0 30px ' + opts.color + ' inset'})

  hoverOff = (event) ->
    $this
      .stop()
      .animate({shadow: '0 0 0px ' + opts.color + ' inset'})

  $this
    .hover hoverOn, hoverOff
