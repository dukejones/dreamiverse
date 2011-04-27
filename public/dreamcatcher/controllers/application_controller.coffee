$.Controller 'Dreamcatcher.Controllers.Application',

  init: ->
    @metaMenu = new Dreamcatcher.Controllers.MetaMenu $('.rightPanel') if $('.rightPanel')?
    @comment = new Dreamcatcher.Controllers.Comment $('#entryField') if $('#entryField')?
    
  '#bodyClick click': ->
    @metaMenu.hideAllPanels() if @metaMenu? #use subscribe/publish?

$(document).ready ->
  @dreamcatcher = new Dreamcatcher.Controllers.Application $('#body')