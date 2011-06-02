$.Controller 'Dreamcatcher.Controllers.Application',
  
  init: ->
    @initUi()
    
    @metaMenu = new Dreamcatcher.Controllers.MetaMenu $('#metaMenu') if $('#metaMenu').exists()
    @imageBank = new Dreamcatcher.Controllers.ImageBank $("#frame.browser") if $("#frame.browser").exists()
    #@comments = new Dreamcatcher.Controllers.Comments $('#entryField') if $('#entryField').exists()
    @entries = new Dreamcatcher.Controllers.EntryField.Entries $("#entryField .matrix") if $("#entryField .matrix").exists()
    @stream = new Dreamcatcher.Controllers.Stream $("#streamContextPanel") if $("#streamContextPanel").exists()    
    @admin = new Dreamcatcher.Controllers.Admin $('#adminPage') if $('#adminPage').exists()
    
  initUi: (parentEl) ->
    parentEl = $('body') if not parent?
    $('.tooltip', parentEl).each (i, el) =>
      Dreamcatcher.Classes.UiHelper.registerTooltip $(el)
    $('.select-menu', parentEl).each (i, el) =>
      Dreamcatcher.Classes.UiHelper.registerSelectMenu $(el)
    #todo -live query

  # TODO: Possibly refactor into jQuery syntax, and remove all other versions.
  # NOTE: this is not currently working, see fit_to_content.coffee
  fitToContent: (id, maxHeight) ->
    text = if id and id.style then id else document.getElementById(id)
    return 0 if not text
    adjustedHeight = text.clientHeight
    if not maxHeight or maxHeight > adjustedHeight
      adjustedHeight = Math.max(text.scrollHeight, adjustedHeight)
      adjustedHeight = Math.min(maxHeight, adjustedHeight) if maxHeight
      $(text).animate(height: (adjustedHeight + 80) + "px") if adjustedHeight > text.clientHeight



  '#bodyClick click': ->
    @metaMenu.hideAllPanels() if @metaMenu?
    @entries.closeEverythingOpen() if @entries?
    
  #TODO: eventually remove '.comment_body' to apply to all 'textarea's
  '.comment_body keyup': (el) ->
    @fitToContent el.attr("id"),0
    
  '.button.appearance click': (el) ->
    @metaMenu.selectPanel 'appearance'
    
  '#entry-appearance click': (el) ->
    @metaMenu.selectPanel 'appearance'
    
    
  'label.ui-selectmenu-default mouseover': (el) ->
    el.parent().addClass 'default-hover'

  'label.ui-selectmenu-default mouseout': (el) ->
    el.parent().removeClass 'default-hover'  
  
  # radio button check for select-menu
  '.ui-selectmenu-default input[type=radio] click': (el) ->
    ul = $(el).closest 'ul'
    $('li', ul).removeClass 'default'
    $(el).closest('li').addClass 'default'
    
    name = el.attr 'name'
    value = $('a:first',el.closest('li')).data 'value'
    
    user = {}
    user[name] = value
    Dreamcatcher.Models.User.update {user: user}

  ###
  '#new-post-menu a click': (el) ->
    log el.data 'value'
    switch el.data 'value'
      when 'entry'
        @entries.newEntry()
      when 'book'
        @entries.newBook(
  ###
  '#new-post change': (el) ->
    value = el.val()
    switch value
      when 'entry'
        @entries.newEntry()
      when 'book'
        @entries.newBook()
        

$(document).ready ->
  @dreamcatcher = new Dreamcatcher.Controllers.Application $('#body')