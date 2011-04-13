
$(document).ready ->
  setupMetaDropdowns()
  
# init
window.setupMetaDropdowns = ->
  settingsPanel = new SettingsPanel('.settingsPanel')
    
  $.subscribe('toggleSettings', (event) ->
    appearancePanel.contract()
    settingsPanel.contract()
    $('.item.appearance').removeClass('selected')
    
    settingsPanel.toggleView()
  )
  
  # iOS Device Fix
  # Checks if the UserAgent is a iOS device
  ua = navigator.userAgent
  clickEvent = if (ua.match(/iPad/i)) then "touchstart" else "click"
  
  # ipad doubleclick remover for left panel
  $('.leftPanel a').bind( clickEvent, (event)->
    event.preventDefault()
    window.location = $(event.currentTarget).attr('href')
  )

  $('.settingsPanel .trigger').first().bind( clickEvent, (event)->
    $.publish('toggleSettings', [this])
    $('.item.settings').addClass('selected')
  )



  appearancePanel = new AppearancePanel('.appearancePanel')
    
  $.subscribe('toggleAppearance', (event) ->
    appearancePanel.contract()
    settingsPanel.contract()
    $('.item.settings').removeClass('selected')
    
    appearancePanel.toggleView()
  )
  
  $('.appearancePanel .trigger').first().bind( clickEvent, (event)->
    $.publish('toggleAppearance', [this])
    $('.item.appearance').addClass('selected')
  )
  
  $.subscribe('hidePanels', (event) ->
    # close all .panel objects
    appearancePanel.contract()
    settingsPanel.contract()
  )

# Model
class MetaMenu
  constructor: (@name)->
    @$currentMenuButton = $(@name).find('.trigger').first()
    @$currentMenuPanel = $(@name).find('.target').first()
  
  toggleView: ->
    if @$currentMenuPanel.is(":visible")
      @contract()
    else
      @expand()
    
  expand: ->
    bodyClick = '<div id="bodyClick" style="z-index: 1100; cursor: pointer; width: 100%; height: 100%; position: fixed; top: 0; left: 0;" class=""></div>'
    $('body').prepend(bodyClick)
  
    $('html, body').animate({scrollTop:0}, 'slow');
  
    $('#bodyClick').click( (event) =>
      @$currentMenuPanel.hide()
      $('#bodyClick').remove()
      $('.item.settings').removeClass('selected')
      $('.item.appearance').removeClass('selected')
    )
    
    @$currentMenuPanel.show()
    
  contract: ->
    # code to contract menu item
    @$currentMenuPanel.fadeOut(250)
    $('#bodyClick').remove()




# Appearance Model Subclass
class AppearancePanel extends MetaMenu
  constructor: (@name) ->
    super(@name)

    @initBedsheets()
    @initScrolling()
    @initTheme()
    
    @$attachment = @$currentMenuPanel.find('.attachment')    
    @$attachment.find('input').change (event) =>
      $('body').removeClass('fixed, scroll')
      $('body').css('background-attachment', $(event.currentTarget).val())
    
    $('.colorPicker a').bind 'ajax:beforeSend', (xhr, settings)=>
      $('#body').removeClass('dark light').addClass($(xhr.target).attr('id'))
    
    $('.colorPicker a').bind 'ajax:success', (data, xhr, status)->
      $('p.notice').text('Theme has been updated')
    
    $('.colorPicker a').bind 'ajax:error', (xhr, status, error)->
      $('p.alert').text(error)
      
    # setup fixed/scroll positioning
    $('.bedsheets .attachment').bind 'ajax:beforeSend', (xhr, settings)=>
      $('#body').removeClass('scroll fixed').addClass($(xhr.target).attr('id'))
    
    $('.bedsheets .attachment').bind 'ajax:success', (data, xhr, status)->
      $('p.notice').text('Theme has been updated')
    
    $('.bedsheets .attachment').bind 'ajax:error', (xhr, status, error)->
      $('p.alert').text(error)

  # code to display and trigger bedsheet updates                   
  initBedsheets: => 
    if $('#appearancePanel').attr('id')
      
      # display bedsheets here. Need JSON call
      $.getJSON("/images.json?section=Bedsheets", (data) =>     
       
        @$currentMenuPanel.find('.bedsheets ul').html('');
    
        # Add elements for each bedsheet returned
        for node in data
          newElement = '<li data-id="' + node.id + '"><img src="/images/uploads/' + node.id + '-thumb-120.jpg"></li>'
          @$currentMenuPanel.find('.bedsheets ul').append(newElement)
        
        # set bedsheet
        @$currentMenuPanel.find('.bedsheets ul').find('li').click (event) =>
          bedsheetUrl = 'url("/images/uploads/' + $(event.currentTarget).data('id') + '-bedsheet.jpg")'
          $('#body').css('background-image', bedsheetUrl)
      
          if $('#entry_view_preference_attributes_image_id').attr('name')?
            $('#entry_view_preference_attributes_image_id').val($(event.currentTarget).data('id'))
          else if $('#show_entry_mode').attr('name')? 
            @updateEntryViewPreferences($('#showEntry').data('id'),$(event.currentTarget).data('id'),null,null)  
          else
            @updateUserViewPreferences($(event.currentTarget).data('id'),null,null)           
      ) # ends $.getJSON
      
    
  # code to display and trigger scrolling updates  
  initScrolling: =>       
    # for new/edit entry 
    if $('#entry_view_preference_attributes_bedsheet_attachment').attr('id')?        
      $('#scroll,#fixed').click (event) ->
        @scrolling = $(event.currentTarget).attr('id')
        log(@scrolling)
        $('#body').removeClass('fixed scroll').addClass(@scrolling) 
        $('#entry_view_preference_attributes_bedsheet_attachment').val(@scrolling)   
    
    else # for show entry and elsewhere        
      $('#scroll,#fixed').click (event) =>
        @entryId = $('#showEntry').data('id')
        @scrolling = $(event.currentTarget).attr('id')
        log(@scrolling)
        $('#body').removeClass('fixed scroll').addClass(@scrolling) 
        if $('#show_entry_mode').attr('name')?
          @updateEntryViewPreferences(@entryId,null,@scrolling,null)   
        else
          @updateUserViewPreferences(null,@scrolling,null)
    
       
  # code to display and trigger theme updates       
  initTheme: =>        
    # for new/edit entry    
    if $('#entry_view_preference_attributes_theme').attr('id')?  
      $('#light, #dark').click (event) ->
        @newTheme = $(event.currentTarget).attr('id')
        log(@newTheme)
        $('#body').removeClass('dark light').addClass(@newTheme)        
        $('#entry_view_preference_attributes_theme').val(@newTheme)      
           
    else # for show entry and elsewhere
      $('#light, #dark').click (event) =>
        @entryId = $('#showEntry').data('id')
        @newTheme = $(event.currentTarget).attr('id')
        log(@newTheme) 
        $('#body').removeClass('dark light').addClass(@newTheme) 
        if $('#show_entry_mode').attr('name')?
          @updateEntryViewPreferences(@entryId,null,null,@newTheme)   
        else
          @updateUserViewPreferences(null,null,@newTheme)            



  updateEntryViewPreferences: (@entryId,@bedsheetId,@scrolling,@theme)->
    $.ajax {
      type: 'POST'
      url: "/entries/#{@entryId}/set_view_preferences"
      data:
        bedsheet_id: @bedsheetId if @bedsheetId?
        scrolling: @scrolling if @scrolling?
        theme: @theme if @theme?
        success: (data, status, xhr) ->
          success = true
     }
  

    updateUserViewPreferences: (@bedsheetId,@scrolling,@theme)->
      $.ajax {
        type: 'POST'
        url: "/user/set_view_preferences"
        data:
          bedsheet_id: @bedsheetId if @bedsheetId?
          scrolling: @scrolling if @scrolling?
          theme: @theme if @theme?
          success: (data, status, xhr) ->
            success = true
       }


# Settings Model Subclass
class SettingsPanel extends MetaMenu
  constructor: (@name)->
    super(@name)
    
    # Only runs the initial dropdown change() listener after the first call
    @firstRun = true
    
    @$defaultSharingSelect = @$currentMenuPanel.find('.sharingList')
    @$defaultSharing = @$currentMenuPanel.find('.sharingList').val()
    @$authorizeAllFollows = @$currentMenuPanel.find('.authFollow').is(':checked')
    @$facebookSharing =  @$currentMenuPanel.find('.fbShare').is(':checked')
    
    
    # setup default sharing dropdown change
    $('#sharingList').change( (event) =>
      switch $(event.currentTarget).find('option:selected')[0].value
        when "500" then $('.sharingIcon').css('background', 'url(/images/icons/sharing-24-hover.png) no-repeat center transparent')
        when "200" then $('.sharingIcon').css('background', 'url(/images/icons/friend-24.png) no-repeat center transparent')
        when "150" then $('.sharingIcon').css('background', 'url(/images/icons/friend-follower-24.png) no-repeat center transparent')
        when "50" then $('.sharingIcon').css('background', 'url(/images/icons/anon-24-hover.png) no-repeat center transparent')
        when "0" then $('.sharingIcon').css('background', 'url(/images/icons/private-24-hover.png) no-repeat center transparent')
      
      if !@firstRun
        @updateDefaultSharing($(event.currentTarget).find('option:selected')[0].value)
      @firstRun = false
    )
    
    # setup fb unlink UI update
    $('#fbLink').bind 'ajax:success', (event, xhr, status)->
      newElement = '<a id="fbLink" href="/auth/facebook" class="linkAccount">link account</a>'
      
      #remove old link
      $('#fbLink').remove()
      
      #display new link
      $('.network').append(newElement)
    
    # setup change password fields
    $('form#change_password').bind 'ajax:beforeSend', (xhr, settings)->
      $('.changePassword .target').hide()
    
    $('form#change_password').bind 'ajax:success', (data, xhr, status)->
      $('p.notice').text(xhr.message)
      if xhr.errors
        for error, message of xhr.errors
          $('#user_' + error).prev().text(message[0])
        # open the panel back up
        $('.changePassword .target').slideDown(250)
      else
        $('#change_password .error').text('')
        $('#user_old_password, #user_password, #user_password_confirmation').val('')
    
    # Setup cancel button on change password
    @$currentMenuPanel.find('.cancel').click =>
      @$currentMenuPanel.find('.changePasswordForm').hide()
      $('#user_password').val('')
      $('#user_password_confirmation').val('')
    
    $('form#change_password').bind 'ajax:error', (xhr, status, error)->
      #$('p.alert').text(xhr.error)
      log xhr.errors
      
    
    #setup Default Sharing dropdown
    @$defaultSharingSelect.val(@$currentMenuPanel.find('.defaultSharing').data('id'))
    $('#sharingList').change()
    
  updateDefaultSharing: (sharingLevel) ->
    
    $.ajax {
      type: 'PUT'
      url: '/user.json'
      dataType: 'json'
      data:
        "user[default_sharing_level]": parseInt(sharingLevel)
      success: (data, status, xhr) =>
    }