$.Controller 'Dreamcatcher.Controllers.Application',

  init: ->
    @metaMenu = new Dreamcatcher.Controllers.MetaMenu $('.rightPanel') if $('.rightPanel')?
    @ibManager = new Dreamcatcher.Controllers.IbManager($("#frame.manager")) if ($("#frame.manager").length > 0)
    
  '#bodyClick click': ->
    @metaMenu.hideAllPanels() if @metaMenu? #use subscribe/publish?

$(document).ready ->
  @dreamcatcher = new Dreamcatcher.Controllers.Application $('#body')