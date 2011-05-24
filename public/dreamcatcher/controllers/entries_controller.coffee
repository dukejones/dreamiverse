$.Controller 'Dreamcatcher.Controllers.Entries',
  
  fields: ['#entry_title','#entry_body','#sharing-list','#entryType-list']
  interval: 5000
  userModel: Dreamcatcher.Models.User
  
  init: ->
    @entryCookie = new Dreamcatcher.Classes.CookieHelper 'dc_new_entry',true
    @posted = false
    @retrieveState()
    @initSelectMenu()
    @saveState()
    
  saveState: ->
    return if @posted
    entryBody = $('#entry_body').val().trim()
    if entryBody.length > 0 
      entry = {}
      entry[field] = $(field).val() for field in @fields
      entry['#currentImages'] = $('#currentImages').html()
      @entryCookie.set entry
    setTimeout =>
      @saveState()
    , @interval
  
  retrieveState: ->
    entry = @entryCookie.get()
    if entry?
      if confirm 'you have an unsaved entry.\n\nwould you like to bring it back ?'
        @stateRetrieved = true
        $(field).val entry[field] for field in @fields
        $('#currentImages').html entry['#currentImages']
    @clearState()
  
  clearState: ->
    @entryCookie.clear()
  
  '#entry_submit click': ->
    @posted = true
    @clearState()
    
  initSelectMenu: ->
    # iterates through each select menu radio
    $('.select-menu-radio').each (i, el) =>
      id = $(el).attr 'id'
      defaultValue = $(el).data 'id'
      
      $(el).val defaultValue if not @stateRetrieved
      
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
