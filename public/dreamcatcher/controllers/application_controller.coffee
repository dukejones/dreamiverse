$.Controller 'Dreamcatcher.Controllers.Application',

  init: ->
    @metaMenu = new Dreamcatcher.Controllers.MetaMenu $('.rightPanel') if $('.rightPanel').exists()
    @comment = new Dreamcatcher.Controllers.Comment $('#entryField') if $('#entryField').exists()


    # TOOL TIPS
    $('#sharing-list-menu label').tooltip(
      track: true,
      delay: 0,
      showURL: false,
      showBody: " - ",
      fade: 250 
    );

    $('#entryOptions .addTheme').tooltip(
      track: true,
      delay: 0,
      showURL: false,
      showBody: " - ",
      fade: 250 
    );

    $('#entryOptions .date').tooltip(
      track: true,
      delay: 0,
      showURL: false,
      showBody: " - ",
      fade: 250 
    );

    $('#metaMenu .stream').tooltip(
      track: true,
      delay: 0,
      showURL: false,
      showBody: " - ",
      fade: 250 
    );

    $('#metaMenu .home').tooltip(
      track: true,
      delay: 0,
      showURL: false,
      showBody: " - ",
      fade: 250 
    );
    $('#metaMenu .dreamstars').tooltip(
      track: true,
      delay: 0,
      showURL: false,
      showBody: " - ",
      fade: 250 
    );

    $('#metaMenu .searchIcon').tooltip(
      track: true,
      delay: 0,
      showURL: false,
      showBody: " - ",
      fade: 250 
    );

    $('#metaMenu .randomDream').tooltip(
      track: true,
      delay: 0,
      showURL: false,
      showBody: " - ",
      fade: 250 
    );


    $('#metaMenu .logOut').tooltip(
      track: true,
      delay: 0,
      showURL: false,
      showBody: " - ",
      fade: 250 
    );

    # STREAM FILTER - entry type
    $('#entry-filter').selectmenu(
      style: 'popup'
      menuWidth: "200px"
    )
    # STREAM FILTER - user type
    $('#users-filter').selectmenu(
      style: 'popup'
      menuWidth: "200px"
    )

    # NEW ENTRY - entry type
    $('#entryType-list').selectmenu(
      icons:[
        {find: '.dream'}
        {find: '.vision'}
        {find: '.experience'}
        {find: '.article'}
        {find: '.journal'}
      ]
      positionOptions: {
        offset: "0 -37px"}
      )
    # NEW ENTRY - sharing level
    $('#sharing-list').selectmenu(
      icons:[
        {find: '.everyone'}
        {find: '.list'}
        {find: '.followers'}
        {find: '.anon'}
        {find: '.private'}
      ]
      style: 'popup'
      menuWidth: "160px"
      )

  #TODO: Possibly refactor into jQuery syntax, and remove all other versions.
  fitToContent: (id, maxHeight) ->
    text = if id and id.style then id else document.getElementById(id)
    return 0 if not text
    adjustedHeight = text.clientHeight
    if not maxHeight or maxHeight > adjustedHeight
      adjustedHeight = Math.max(text.scrollHeight, adjustedHeight)
      adjustedHeight = Math.min(maxHeight, adjustedHeight) if maxHeight
      text.style.height = adjustedHeight + 80 + 'px' if adjustedHeight > text.clientHeight    

  '#bodyClick click': ->
    @metaMenu.hideAllPanels() if @metaMenu? #use subscribe/publish?
    
  #TODO: eventually remove '.comment_body' to apply to all 'textarea's
  '.comment_body keyup': (el) ->
    @fitToContent el.attr("id"),0
    
  '.button.appearance click': (el) ->
    @metaMenu.selectPanel 'appearance'
    
  '.addTheme .img click': (el) ->
    @metaMenu.selectPanel 'appearance'

$(document).ready ->
  @dreamcatcher = new Dreamcatcher.Controllers.Application $('#body')