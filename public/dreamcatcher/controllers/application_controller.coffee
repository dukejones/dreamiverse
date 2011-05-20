$.Controller 'Dreamcatcher.Controllers.Application',

  userModel: Dreamcatcher.Models.User
  
  init: ->
    @metaMenu = new Dreamcatcher.Controllers.MetaMenu $('.rightPanel') if $('.rightPanel').exists()
    @ibBrowser = new Dreamcatcher.Controllers.IbBrowser $("#frame.browser") if $("#frame.browser").exists()
    @entry = new Dreamcatcher.Controllers.Entry $("#newEntry") if $("#newEntry").exists()
    @comment = new Dreamcatcher.Controllers.Comments $('#entryField') if $('#entryField').exists()
    @initSelectMenu()
    @initTooltips()

  initTooltips: ->
    $('.tooltip').tooltip {
      track: true
      delay: 0
      showURL: false
      showBody: ' - '
      fade: 250
    }
    ###
    TODO: 
    $('#entryOptions .date').tooltip -doesn't work - weird
    $('#sharing-list-menu label').tooltip(
    ###
  
  initSelectMenu: ->
    $('.select-menu').selectmenu(
      style: 'popup'
      menuWidth: "200px"
    )
    
    $('.select-menu-radio').each (i, el) =>
      $(el).selectmenu {
        style: if $(el).hasClass('dropdown') then 'dropdown' else 'popup'
        menuWidth: '200px'
        format: (text) =>
          return @view("selectMenuFormat",text)
      }
    # hack - move labels to outside the a tag.
    $('.ui-selectmenu-menu label.ui-selectmenu-default').each (i,el) ->
      $(el).appendTo $(el).parent().parent()
      

  '.ui-selectmenu-default input click': (el) ->
    value = el.closest('li').attr('class')
    data = {}
    switch el.closest('ul').attr('id').replace('-list-menu','')
      when 'entryType'
        data['user[default_entry_type]'] = value
      when 'sharing'
        data['user[default_sharing_level]'] = value
    @userModel.update { data }

  # TODO: Possibly refactor into jQuery syntax, and remove all other versions.
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
    
  '#entry-appearance click': (el) ->
    @metaMenu.selectPanel 'appearance'

$(document).ready ->
  @dreamcatcher = new Dreamcatcher.Controllers.Application $('#body')
  ###
  $(window).unload ->
    if not confirm 'are you sure?'
      window.location.reload()
      return false
    #history.go -1
  ###