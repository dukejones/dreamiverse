$.Controller 'Dreamcatcher.Controllers.Application',
  
  #- constructor
  
  init: ->
    $('#metaMenu').metaMenu()
    $('#entryField .matrix.index').dreamField()
    $('#entryField .matrix.books').books()
    $('#entryField .matrix.stream').dreamStream()
    $('#entryField #showEntry').showEntry()
    $('#entryField #newEditEntry').newEditEntry()
    
    $('#totem').contextPanel()
        
    @images     = new Dreamcatcher.Controllers.Images.Images        $("#frame.browser")   if $("#frame.browser").exists()
    @admin      = new Dreamcatcher.Controllers.Admin                $('#adminPage')       if $('#adminPage').exists()
    
    @publish 'dom.added', $('#body')    
    @bind window, 'popstate', => @publishHistory window.location.pathname
      
  #.spine-nav, a.stream, a.entries, a.prev, a.next, a.editEntry 
  'a.history click': (el, ev) ->
    ev.preventDefault()
    href = el.attr 'href'
    window.history.pushState null, null, href
    @publish 'history.change', href
    
  'history.change subscribe': (called, href) ->
    hrefSplit = href.split '/'
    controller = 'entries'
    action = 'show'
    data = {}
    
    if hrefSplit.length > 1
      if hrefSplit[1] in ['books']
        controller = hrefSplit[1]
      else if hrefSplit[1] in ['stream']
        action = hrefSplit[1]
      else
        data.username = hrefSplit[1]
      
    if hrefSplit.length > 2
      if hrefSplit[2] is 'new'
        action = 'new' 
      else
        data.id = hrefSplit[2]
      
      if hrefSplit.length > 3
        action = hrefSplit[3] if hrefSplit.length > 3
  
    else
      action = 'index'
  
    log "#{controller}.#{action}  "+data
    @publish "#{controller}.#{action}", data
      
  #- setup ui elements
  
  initUi: (parentEl) ->
    parentEl = $('body') if not parentEl?
    $('.tooltip', parentEl).each (i, el) =>
      Dreamcatcher.Classes.UiHelper.registerTooltip $(el)
    $('.select-menu', parentEl).each (i, el) =>
      Dreamcatcher.Classes.UiHelper.registerSelectMenu $(el)
    $('textarea', parentEl).each (i, el) ->
      fitToContent $(this).attr('id'), 0
      
  'dom.added subscribe': (called, data) ->
    @initUi data
    
  #- appearance (bedsheet, scroll  & theme) change
  'appearance.change subscribe': (called, data) ->
    #if no data is passed, then use the user default settings
    if not data?
      data = $('#userInfo').data 'viewpreference'

    return if not data.image_id?

    bedsheetUrl = "/images/uploads/#{data.image_id}-bedsheet.jpg"
    return if $('#backgroundReplace').css('background-image').indexOf(bedsheetUrl) isnt -1

    #todo: should include font size & float?
    if data.bedsheet_attachment?
      $('#body').removeClass('scroll fixed')
      $('#body').addClass data.bedsheet_attachment
    if data.theme?
      $('#body').removeClass('light dark')
      $('#body').addClass data.theme

    img = $("<img src='#{bedsheetUrl}' style='display:none' />")
    $(img).load ->
      $('#bedsheetScroller .bedsheet .spinner').remove() #remove if exists
      #todo: make style
      $('#backgroundReplace').css 'background-image', "url('#{bedsheetUrl}')"
      $('#backgroundReplace').fadeIn 500, =>
        $('#backgroundReplace').hide()
        $('#body').css 'background-image', "url('#{bedsheetUrl}')"
    $('body').append img
    
  #- catch any body click event

  '#bodyClick click': ->
    @publish 'body.clicked' 
    
  #- fit to content event
    
  'textarea keyup': (el) ->
    fitToContent el.attr('id'), 0
    
  '.button.appearance, #entry-appearance click': (el) -> #todo: merge class name
    @publish 'menu.show', 'appearance'
  
  #- select-menu events - todo: move into own controller?
    
  'label.ui-selectmenu-default mouseover': (el) ->
    el.parent().addClass 'default-hover'

  'label.ui-selectmenu-default mouseout': (el) ->
    el.parent().removeClass 'default-hover'  
  
  '.ui-selectmenu-default input[type=radio] click': (el) ->
    # radio button check for select-menu
    #todo: publish
    ul = $(el).closest 'ul'
    $('li', ul).removeClass 'default'
    $(el).closest('li').addClass 'default'
    
    name = el.attr 'name'
    value = $('a:first',el.closest('li')).data 'value'
    
    user = {}
    user[name] = value
    Dreamcatcher.Models.User.update {user: user}
  
$(document).ready ->
  @dreamcatcher = new Dreamcatcher.Controllers.Application $('#body')