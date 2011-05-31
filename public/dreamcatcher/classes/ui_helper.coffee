$.Class 'Dreamcatcher.Classes.UiHelper',{
  
  registerTooltip: (el) ->
    left = el.hasClass 'left'
    el.tooltip {
      track: true
      delay: 0
      showURL: false
      showBody: ' - '
      fade: 250
      positionLeft: left
      top: 20 if left
    }
    
  registerSelectMenu: (el) ->
    id = el.attr 'id'
    defaultValue = el.data 'id'
    
    dropdown = el.hasClass 'dropdown'
    radio = el.hasClass 'radio'
    offset = el.hasClass 'offset'
    
    
    options = {
      style: 'popup'
      menuWidth: '200px'
    }
    
    if dropdown
      $.extend options, {
        style: 'dropdown'
        positionOptions:
          offset: "0px -37px"
      }
      
    if offset
      $.extend options, {
        menuWidth: '174px'
        positionOptions: {
          offset: '-136px -35px'
        }
      }
    
    if radio
      $.extend options, {
        menuWidth: '156px'
        format: (text) =>
          return $.View '//dreamcatcher/views/select_menu_format.ejs', {
            text: text
            value: text
            name: id
          }
      }  
      $(el).val defaultValue
    
    el.selectmenu options

    if radio
      $("##{id}-menu label.ui-selectmenu-default").each (i,el) ->
        li = $(el).closest('li')
        value = $('a',li).data 'value'
        isDefault = value is defaultValue
        li.addClass 'default' if isDefault

        # checks the radio button if it's the default value
        $('input[type="radio"]',el).attr 'checked', isDefault

        # moves the radio button outside the a tag (so it doesn't conflict)
        $(el).appendTo li
    
},{}