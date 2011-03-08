
$(document).ready ->
  setupMetaDropdowns()
  
# init
window.setupMetaDropdowns = ->
  settingsPanel = new SettingsPanel('.settingsPanel')
    
  $.subscribe('toggleSettings', (event) ->
    appearancePanel.contract()
    settingsPanel.contract()
    
    settingsPanel.toggleView()
  )
  
  # iOS Device Fix
  # Checks if the UserAgent is a iOS device
  ua = navigator.userAgent
  clickEvent = if (ua.match(/iPad/i)) then "touchstart" else "click"
  
  $('.settingsPanel .trigger').first().bind( clickEvent, (event)->
    $.publish('toggleSettings', [this])
  )
  
  appearancePanel = new AppearancePanel('.appearancePanel')
  appearancePanel.displayBedsheets()
    
  $.subscribe('toggleAppearance', (event) ->
    appearancePanel.contract()
    settingsPanel.contract()
    
    appearancePanel.toggleView()
  )
  
  $('.appearancePanel .trigger').first().bind( clickEvent, (event)->
    $.publish('toggleAppearance', [this])
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
    )
    
    @$currentMenuPanel.show()
    
  contract: ->
    # code to contract menu item
    @$currentMenuPanel.fadeOut('fast')
    $('#bodyClick').remove()
    

# Appearance Model Subclass
class AppearancePanel extends MetaMenu
  constructor: (@name) ->
    super(@name)
    @setupThemeSelector()
    
    @$attachment = @$currentMenuPanel.find('.attachment')
    
    @$attachment.find('input').change (event) =>
      $('body').removeClass('fixed, scroll')
      $('body').css('background-attachment', $(event.currentTarget).val())
    
    # setup theme colorPicker
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
          
    
  setupThemeSelector: ->
    @$currentMenuPanel.find('.buttons .sun, .buttons .moon').click (event) =>
      @newTheme = $(event.currentTarget).attr('id')
      if $('#entry_view_preference_theme').attr('id')?
        $('#entry_view_preference_theme').val(@newTheme)
        
  displayBedsheets: -> 
    # code to display bedsheets here. Need JSON call
    # $.publish('follow/changing', [node])
    $.getJSON("/images.json?section=Bedsheets", (data) =>
      
      @$currentMenuPanel.find('.bedsheets ul').html('');
    
      # Add elements for each bedsheet returned
      for node in data
        newElement = '<li data-id="' + node.id + '"><img src="/images/uploads/' + node.id + '-thumb-120.' + node.format + '"></li>'
        @$currentMenuPanel.find('.bedsheets ul').append(newElement)
    
      @$currentMenuPanel.find('.bedsheets ul').find('li').click (event) =>
        bedsheetUrl = 'url("/images/uploads/' + $(event.currentTarget).data('id') + '-bedsheet.jpg")'
        $('#body').css('background-image', bedsheetUrl)
      
        if $('#entry_view_preference_attributes_image_id').attr('name')?
          @updateEntryBedsheet($(event.currentTarget).data('id'))
        else
          @updateUserBedsheet($(event.currentTarget).data('id'))
                
      )

  updateUserBedsheet: (@bedsheet_id)->
    $.ajax {
      type: 'POST'
      url: '/user/bedsheet'
      data:
        bedsheet_id: @bedsheet_id
      success: (data, status, xhr) =>
        success = true
    }
  
  updateEntryBedsheet: (bedsheet_id)->
    $('#entry_view_preference_attributes_image_id').val(bedsheet_id)
  

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
    
    # setup saved locations
    $('.modifyLocationView .cancel').click( (event) ->
      $(event.currentTarget).parent().prev().show()
      $(event.currentTarget).parent().hide()
    )
    
    $('form#addLocationForm').bind 'ajax:beforeSend', (xhr, settings)=>
      $('#addLocationForm').hide()
      $('.locationView').show()
      #log xhr.target.new_location[name]
    
    $('form#addLocationForm').bind 'ajax:success', (data, xhr, status)->
      $('#locationList').append(xhr)
      $('p.notice').text('Profile has been updated')
    
    $('form#addLocationForm').bind 'ajax:error', (xhr, status, error)->
      $('p.alert').text(error)
    
    $('.locationForm input:radio').change( (event) ->
      $('.location input:radio').each( (index, value) ->
        $(value).parent().removeClass('selected')
      )
      $(event.currentTarget).parent().addClass('selected')
    )
    
    # setup default sharing dropdown change
    $('#sharingList').change( (event) =>
      switch $(event.currentTarget).find('option:selected').text()
        when "Everyone" then $('.sharingIcon').attr('src', '/images/icons/everyone-16.png')
        when "Friends only" then $('.sharingIcon').attr('src', '/images/icons/friend-16.png')
        when "Anonymous" then $('.sharingIcon').attr('src', '/images/icons/mask-16.png')
        when "Private" then $('.sharingIcon').attr('src', '/images/icons/lock-16.png')
      
      if !@firstRun
        @updateDefaultSharing($(event.currentTarget).find('option:selected').text())
      @firstRun = false
    )
    
    # setup change password fields
    $('form#change_password').bind 'ajax:beforeSend', (xhr, settings)->
      $('.changePassword .target').hide()
    
    $('form#change_password').bind 'ajax:success', (data, xhr, status)->
      $('p.notice').text(xhr.message)
      if xhr.errors
        for error, message of xhr.errors
          $('#user_' + error).prev().text(message[0])
        # open the panel back up
        $('.changePassword .target').slideDown()
      else
        $('#change_password .error').text('')
        $('#user_old_password, #user_password, #user_password_confirmation').val('')
    
    $('form#change_password').bind 'ajax:error', (xhr, status, error)->
      #$('p.alert').text(xhr.error)
      log xhr.errors
      
    
    #setup Default Sharing dropdown
    @$defaultSharingSelect.val(@$currentMenuPanel.find('.defaultSharing').data('id'))
    $('#sharingList').change()
    
  updateDefaultSharing: (newSharingLevel) ->
    
    switch newSharingLevel
        when "Everyone" then sharingLevel = 500
        when "Friends only" then sharingLevel = 200
        when "Anonymous" then sharingLevel = 50
        when "Private" then sharingLevel = 0
    
    $.ajax {
      type: 'PUT'
      url: '/user.json'
      dataType: 'json'
      data:
        "user[default_sharing_level]": parseInt(sharingLevel)
      success: (data, status, xhr) =>
        alert 'updated default sharing level!'
    }