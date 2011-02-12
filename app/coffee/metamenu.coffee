
$(document).ready ->
  setupMetaDropdowns()
  
# init
window.setupMetaDropdowns = ->
  settingsPanel = new SettingsPanel('.settingsPanel')
    
  $.subscribe('toggleSettings', (event) ->
    settingsPanel.toggleView()
  )

  $('.settingsPanel .trigger').first().click( (event)->
    $.publish('hidePanels');
    $.publish('toggleSettings', [this])
  )
  
  appearancePanel = new AppearancePanel('.appearancePanel')
  appearancePanel.displayBedsheets()
    
  $.subscribe('toggleAppearance', (event) ->
    appearancePanel.toggleView()
  )

  $('.appearancePanel .trigger').first().click( (event)->
    $.publish('hidePanels');
    $.publish('toggleAppearance', [this])
  )
  
  # close all panels listener
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
  displayBedsheets: -> 
    # code to display bedsheets here. Need JSON call
    # $.publish('follow/changing', [node])
    $.getJSON("/images.json?section=Bedsheets", (data) =>
      
      @$currentMenuPanel.find('.bedsheets ul').html('');
      
      for node in data
        newElement = '<li><img src="/images/uploads/' + node.id + '-126x126.' + node.format + '"></li>'
        @$currentMenuPanel.find('.bedsheets ul').append(newElement)
    )
  

# Settings Model Subclass
class SettingsPanel extends MetaMenu
  constructor: (@name)->
    super(@name)
    
    @$defaultSharing = @$currentMenuPanel.find('.sharingList').val()
    @$authorizeAllFollows = @$currentMenuPanel.find('.authFollow').is(':checked')
    @$facebookSharing =  @$currentMenuPanel.find('.fbShare').is(':checked')
    
    # setup saved locations
    $('.modifyLocationView .cancel').click( (event) ->
      $(event.currentTarget).prev().show()
      $(event.currentTarget).parent().hide()
    )
    
    $('.modifyLocationView .confirm').click( (event) ->
      $(event.currentTarget).parent().hide().prev().show()
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
  
  changePassword: ->
    alert "change password"
  