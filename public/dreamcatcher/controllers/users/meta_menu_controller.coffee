$.Controller 'Dreamcatcher.Controllers.Users.MetaMenu',

  init: ->
    @setupiOSfix()
    @hideAllPanels()
    
  # iOS Device Fix
  # Checks if the UserAgent is a iOS device
  setupiOSfix: ->
    clickEvent = if (navigator.userAgent.match(/iPad/i)) then "touchstart" else "click"
    # ipad doubleclick remover for left panel
    $('.leftPanel a').bind clickEvent,(ev) ->
      ev.preventDefault()
      window.location = $(ev.currentTarget).attr 'href'

  expandSelectedPanel: ->
    $('html, body').animate {scrollTop:0},'slow' if not $('#body').hasClass 'float'
    @currentPanel.showPanel()
    $('#bodyClick').show()

  hideAllPanels: ->
    $('#settingsPanel,#appearancePanel').fadeOut 250
    $('#bodyClick').hide()
    $('.item.settings,.item.appearance').removeClass 'selected'
    
  selectPanel: (name) ->
    $(".item.trigger.#{name}").addClass 'selected'
  
    switch name
      when "settings"
        @settingsPanel = new Dreamcatcher.Controllers.Users.Settings $("#settingsPanel") if not @settingsPanel?
        @currentPanel = @settingsPanel
      when "appearance"
        @appearancePanel = new Dreamcatcher.Controllers.Users.Appearance $("#appearancePanel") if not @appearancePanel?
        @currentPanel = @appearancePanel
      
    @expandSelectedPanel()


  '.item.settings,.item.appearance click': (el) ->
    expanded = el.hasClass('selected')
    @hideAllPanels()
    return if expanded
    panelName = $('.target:first',el.parent()).attr('id').replace('Panel','')
    @selectPanel panelName
    

