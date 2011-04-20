$.Controller 'Dreamcatcher.Controllers.Application',

  load: ->
    @metaMenu = new Dreamcatcher.Controllers.MetaMenu($('.rightPanel'))
    
  '#bodyClick click': ->
    @metaMenu.hideAll() if @metaMenu?

$(document).ready ->
  @dreamcatcher = new Dreamcatcher.Controllers.Application($('#body'))