$.Controller 'Dreamcatcher.Controllers.Application',
  
  #- constructor
  
  init: ->
    @publish 'dom', $('#body') 
    
  #- controllers
  
  setupControllers: ->
    @metaMenu   = new Dreamcatcher.Controllers.MetaMenu   $('#metaMenu')            if $('#metaMenu').exists()
    @imageBank  = new Dreamcatcher.Controllers.ImageBank  $("#frame.browser")       if $("#frame.browser").exists()
    @comments   = new Dreamcatcher.Controllers.Comments   $('#entryField')          if $('#entryField .comments').exists()
    @entries    = new Dreamcatcher.Controllers.EntryField.Entries $("#entryField")  if $("#entryField").exists()
    @stream     = new Dreamcatcher.Controllers.Stream     $("#streamContextPanel")  if $("#streamContextPanel").exists()    
    @admin      = new Dreamcatcher.Controllers.Admin      $('#adminPage')           if $('#adminPage').exists()
    
  #- setup ui elements
  
  initUi: (parentEl) ->
    parentEl = $('body') if not parentEl?
    $('.tooltip', parentEl).each (i, el) =>
      Dreamcatcher.Classes.UiHelper.registerTooltip $(el)
    $('.select-menu', parentEl).each (i, el) =>
      Dreamcatcher.Classes.UiHelper.registerSelectMenu $(el)
      
  'dom subscribe': (called, data) ->
    @initUi data

  '#bodyClick click': ->
    @publish 'bodyClick'
    @metaMenu.hideAllPanels() if @metaMenu? #todo: publish
    
  #- fit to content event
  
  'textarea keyup': (el) ->
    fitToContent el.attr('id'), 0
    
  #- appearance menu
  #todo: checkout where used
    
  '.button.appearance, #entry-appearance click': (el) -> #todo: merge class name
    @metaMenu.selectPanel 'appearance' #todo: publish?
  
  #- select-menu events - move into own controller?
    
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

  #meta Menu - mov?

  '#new-post change': (el) ->
    @historyAdd {
      controller: el.val()
      action: 'new'
    }
    #todo: issue with selecting same again
    
  '#metaMenu .newEntry click': (el) ->
    @historyAdd {
      controller: 'entry'
      action: 'new'
    }
    
  #own context panel one?
    
  '#contextPanel .avatar, #contextPanel .book click': (el) ->
    #todo: could make same class
    @historyAdd {
      controller: 'entry'
      action: 'field'
    }

$(document).ready ->
  @dreamcatcher = new Dreamcatcher.Controllers.Application $('#body')