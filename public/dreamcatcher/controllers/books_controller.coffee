$.Controller 'Dreamcatcher.Controllers.Books',

  init: ->
    @initSelectMenu()
    
  initSelectMenu:  ->
    $('#new-list').selectmenu {
      style: 'popup'
      menuWidth: '156px'
      positionOptions: {
        offset: '0 -37px'
      }
      style: 'dropdown'
    }
    
  showPage: (el, page) ->
    bookEl = el.closest '.book'
    $('.open', bookEl).children().hide()
    $(".#{page}-panel", bookEl).show()
    
  closeBook: (el) ->
    bookEl = el.closest '.book'
    $('.open', bookEl).hide()
    $('.closed', bookEl).show()
    
  openBook: (el) ->
    bookEl = el.closest '.book'
    $('.open', bookEl).show()
    $('.closed', bookEl).hide()
    
  '.book .control-panel .color click': (el) ->
    @showPage el, 'color'
    
  '.book .control-panel .coverImage click': (el) ->
    @showPage el, 'cover'
    
  '.book .control-panel .access click': (el) ->
    @showPage el, 'access'
    
  '.book .open .back click': (el) ->
    @showPage el, 'control'
    
  '.book .control-panel .confirm click': (el) ->
    @closeBook el
    
  '.book .closed .edit click': (el) ->
    @openBook el

    