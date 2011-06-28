  
$(document).ready ->
  @dreamcatcher = new Dreamcatcher.Controllers.Application $('#body')
  
$.Controller 'Dreamcatcher.Controllers.Application',
  
  init: (el)->
    @element = $(el)
    @publish 'dom.added', @element

    $('#metaMenu').metaMenu()
    $('#totem').contextPanel() if $('#totem').exists()
    
    $('#entriesIndex').dreamField() if $('#entriesIndex').exists()
    $('#entriesStream').dreamStream() if $('#entriesStream').exists()
    $('#showEntry').showEntry() if $('#showEntry').exists()
    $('#newEditEntry').newEditEntry() if $('#newEditEntry').exists()
    
    $('#adminPage').admin() if $('#adminPage').exists()
    $('#frame.browser').imageBank() if $("#frame.browser").exists()
    
    @bind window, 'popstate', => @publish 'history.change', window.location.pathname
    
    $('input[placeholder], textarea[placeholder]').placeholder() # FF 3.6


  #- setup ui elements
  initUi: (parentEl) ->
    $('textarea').each (i, el) ->
      fitToContent $(this).attr('id'), 0
    $('.tooltip').each (i, el) =>
      UiHelper.registerTooltip $(el)
    $('.select-menu').each (i, el) =>
      UiHelper.registerSelectMenu $(el)
  

  ## Event Binding ##
  
  #.spine.history, a.stream, a.entries, a.prev, a.next, a.editEntry 
  'a.history click': (el, ev) ->
    return unless $('#entryField').exists()
    ev.preventDefault()
    href = el.attr 'href'
    window.history.pushState null, null, href
    @publish 'history.change', href
    
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
  
  
  ## Subscriptions ##
  
  'history.change subscribe': (called, href) ->
    # entries_show = /^\/(\w+)\/(\d+)$/
    # stream = /^\/stream$/
    # books = /^\/books\/?(\w*)/
    # if (match = entries_show.exec(href))?
    #   @publish 'entries.show', {username: match[1], id: match[2]}
    # if (match = books.exec(href))?
    #   if (action = match[1])?
    #   else
    #     action = 'index'
    #   @publish "books.#{action}", data
    # if (match = stream.exec(href))?
    #   @publish 'dreamstream'

    hrefSplit = href.split '/'
    controller = 'entries'
    action = 'show'
    data = {}
    
    if hrefSplit.length > 1
      if hrefSplit[1] is 'books'
        controller = hrefSplit[1]
      else if hrefSplit[1] is 'stream'
        controller = hrefSplit[1]
      else
        data.username = hrefSplit[1]
      
    if hrefSplit.length > 2
      if hrefSplit[2] is 'new'
        action = 'new' 
      else
        data.id = hrefSplit[2]
      
      if hrefSplit.length > 3
        action = hrefSplit[3]
  
    else
      action = 'index'
      
    log "#{controller}.#{action}"
    log data
    @publish "#{controller}.#{action}", data
      
      
  'dom.added subscribe': (called, data) ->
    @initUi data
    
  #- appearance (bedsheet, scroll  & theme) change
  'appearance.change subscribe': (called, data) ->
    #if no data is passed, then use the user default settings
    data = $('#userInfo').data 'viewpreference' unless data?
    return unless data.image_id?

    # TODO: Make this an Image model lookup.   new Image(data.image_id).url('bedsheet')
    bedsheetUrl = "/images/uploads/#{data.image_id}-bedsheet.jpg"
    return unless $('#backgroundReplace').css('background-image').indexOf(bedsheetUrl) is -1

    # todo: should include font size & float?
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
      $('#backgroundReplace').fadeIn 750, =>
        $('#backgroundReplace').hide()
        $('#body').css 'background-image', "url('#{bedsheetUrl}')"
    $('body').append img
    
  'app.loading subscribe': (called, enable=yes) ->
    if enable
      $('#ajax_loading').show()
    else
      $('#ajax_loading').hide()
