$.Controller 'Dreamcatcher.Controllers.Application',

  init: ->
    @metaMenu = new Dreamcatcher.Controllers.MetaMenu($('.rightPanel'))
    
  '#bodyClick click': ->
    @metaMenu.hideAll() if @metaMenu?

$(document).ready ->
  @dreamcatcher = new Dreamcatcher.Controllers.Application($('#body'))