$.Controller 'Dreamcatcher.Controllers.Application',

  userModel: Dreamcatcher.Models.User
  
  init: ->
    @metaMenu = new Dreamcatcher.Controllers.MetaMenu $('.rightPanel') if $('.rightPanel').exists()
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
    $('.tooltip-left').tooltip {
      track: true
      delay: 0
      showURL: false
      showBody: ' - '
      positionLeft: true
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
      $(el).val $(el).data 'id'
      $(el).selectmenu(
        style: if $(el).hasClass('dropdown') then 'dropdown' else 'popup'
        menuWidth: '200px'
        format: (text, value) =>
          return @view 'selectMenuFormat', text
      )

    $('.ui-selectmenu-menu label.ui-selectmenu-default').each (i,el) ->
      $(el).appendTo $(el).parent().parent() # move labels to outside the a tag.
      
  '.ui-selectmenu-default input click': (el) ->
    value = $('a:first',el.closest('li')).data 'value'
    type = el.closest('ul').attr('id').replace('-menu','')
    switch type.replace('-list','')
      when 'entryType'
        @userModel.update {'user[default_entry_type]': value}
      when 'sharing'
        @userModel.update {'user[default_sharing_level]': value}
  

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
    
  '#entry_appearance click': (el) ->
    @metaMenu.selectPanel 'appearance'

$(document).ready ->
  @dreamcatcher = new Dreamcatcher.Controllers.Application $('#body')