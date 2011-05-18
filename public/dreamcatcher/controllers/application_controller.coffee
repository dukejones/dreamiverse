$.Controller 'Dreamcatcher.Controllers.Application',

  userModel: Dreamcatcher.Models.User
  
  init: ->
    @metaMenu = new Dreamcatcher.Controllers.MetaMenu $('.rightPanel') if $('.rightPanel').exists()
    @comment = new Dreamcatcher.Controllers.Comments $('#entryField') if $('#entryField').exists()
    @entry = new Dreamcatcher.Controllers.Entry $("#newEntry") if $("#newEntry").exists()
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
      style: 'dropdown'
      menuWidth: "200px"
      positionOptions:
        offset: "0px -37px"
    )
    
    # iterates through each select menu radio
    $('.select-menu-radio').each (i, el) =>
      id = $(el).attr 'id'
      defaultValue = $(el).data 'id'
      
      $(el).val defaultValue
      
      options = {
        style: 'popup'
        menuWidth: '156px'
        format: (text) =>
         return @view 'selectMenuFormat', {
           text: text
           value: text
           name: id
         }
      }
      if $(el).hasClass 'dropdown'
        options['positionOptions'] = { offset: "0 -37px" }
        options['style'] = 'dropdown'
      
      # sets up the select menu (converts to list)
      $(el).selectmenu options

      # iterates through each label and radio button
      $("##{id}-menu label.ui-selectmenu-default").each (i,el) ->
        li = $(el).closest('li')
        value = $('a',li).data 'value'
        isDefault = value is defaultValue
        li.addClass 'default' if isDefault
        
        # checks the radio button if it's the default value
        $('input[type="radio"]',el).attr 'checked', isDefault
        
        # moves the radio button outside the a tag (so it doesn't conflictg)
        $(el).appendTo li
        
  'label.ui-selectmenu-default mouseover': (el) ->
    el.parent().addClass 'default-hover'

  'label.ui-selectmenu-default mouseout': (el) ->
    el.parent().removeClass 'default-hover'
    
      
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
    
  '#entry-appearance click': (el) ->
    @metaMenu.selectPanel 'appearance'

$(document).ready ->
  @dreamcatcher = new Dreamcatcher.Controllers.Application $('#body')