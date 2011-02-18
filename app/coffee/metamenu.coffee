
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
          
    
  setupThemeSelector: ->
    @$currentMenuPanel.find('.buttons .sun, .buttons .moon').click( (event) =>
      @newTheme = $(event.currentTarget).attr('id')
      $('#view_preference_theme').val(newTheme)
      # $.ajax {
      #         type: 'POST'
      #         url: '/user/theme'
      #         data:
      #           theme: @newTheme
      #         success: (data, status, xhr) =>
      #           success = true
      #       }
    )
    # @$currentMenuPanel.find('.buttons .moon').click( (event) =>
    #       $('#view_preference_theme').val('dark')
    #     )
    #     
  displayBedsheets: -> 
    # code to display bedsheets here. Need JSON call
    # $.publish('follow/changing', [node])
    $.getJSON("/images.json?section=Bedsheets", (data) =>
      
      @$currentMenuPanel.find('.bedsheets ul').html('');
      
      # Add elements for each bedsheet returned
      for node in data
        newElement = '<li data-id="' + node.id + '"><img src="/images/uploads/' + node.id + '-120x120.' + node.format + '"></li>'
        @$currentMenuPanel.find('.bedsheets ul').append(newElement)
      
      @$currentMenuPanel.find('.bedsheets ul').find('li').click (event) =>
        # SUPER TEMP
        
        bedsheetUrl = 'url("/images/uploads/originals/' + $(event.currentTarget).data('id') + '.jpg")'
        $('#body').css('background-image', bedsheetUrl)
        
        if $('#view_preference_image_id').attr('name')?
          @updateEntryBedsheet($(event.currentTarget).data('id'))
        else
          @updateUserBedsheet($(event.currentTarget).data('id'))
          
        
    )
  
  updateUserBedsheet: (@bedsheet_id)->
    #alert "update user bedsheet api call :: " + bedsheet_id
    $.ajax {
      type: 'POST'
      url: '/user/bedsheet'
      data:
        bedsheet_id: @bedsheet_id
      success: (data, status, xhr) =>
        success = true
    }
  
  updateEntryBedsheet: (bedsheet_id)->
    $('#view_preference_image_id').val(bedsheet_id)
  

# Settings Model Subclass
class SettingsPanel extends MetaMenu
  constructor: (@name)->
    super(@name)
    
    @$defaultSharing = @$currentMenuPanel.find('.sharingList').val()
    @$authorizeAllFollows = @$currentMenuPanel.find('.authFollow').is(':checked')
    @$facebookSharing =  @$currentMenuPanel.find('.fbShare').is(':checked')
    
    # setup saved locations
    $('.modifyLocationView .cancel').click( (event) ->
      $(event.currentTarget).parent().prev().show()
      $(event.currentTarget).parent().hide()
    )
    
    $('.modifyLocationView .save').click( (event) ->
      $(event.currentTarget).parent().hide()
      $(event.currentTarget).prev().show()
      alert "SEND SAVED LOCATION DATA TO SERVER"
    )
    
    $('.locationForm input:radio').change( (event) ->
      $('.locations input:radio').each( (index, value) ->
        $(value).parent().removeClass('selected')
      )
      $(event.currentTarget).parent().addClass('selected')
    )
    
    # setup default sharing dropdown change
    $('.sharingList').change( (event) ->
      switch $(this).val()
        when "Everyone" then $('.sharingIcon').attr('src', '/images/icons/everyone-16.png')
        when "Friends Only" then $('.sharingIcon').attr('src', '/images/icons/friend-16.png')
        when "Anonymous" then $('.sharingIcon').attr('src', '/images/icons/mask-16.png')
        when "Private" then $('.sharingIcon').attr('src', '/images/icons/lock-16.png')
    )
    
    # setup change password fields
    $('form#change_password').bind 'ajax:beforeSend', (xhr, settings)->
      $('.changePassword .target').hide()
    
    $('form#change_password').bind 'ajax:success', (data, xhr, status)->
      $('p.notice').text('Password has been updated')
    
    $('form#change_password').bind 'ajax:error', (xhr, status, error)->
      $('p.alert').text(error)
  