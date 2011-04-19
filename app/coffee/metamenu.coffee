
$(document).ready ->
  setupMetaDropdowns()
  
# init
window.setupMetaDropdowns = ->
  appearancePanel = new AppearancePanel('.appearancePanel')
  appearancePanel.expand()

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
    $('#bodyClick').show()
    $('html, body').animate({scrollTop:0}, 'slow');
  
    $('#bodyClick').click( (event) =>
      @$currentMenuPanel.hide()
      $('#bodyClick').hide()
      $('.item.settings, .item.appearance').removeClass('selected')
    )
    @$currentMenuPanel.show()
    
  contract: ->
    @$currentMenuPanel.fadeOut(250)
    $('#bodyClick').remove()

# Appearance Model Subclass
class AppearancePanel extends MetaMenu
  constructor: (@name) ->
    super(@name)
