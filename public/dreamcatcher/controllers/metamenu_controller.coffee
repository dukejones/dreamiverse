$.Controller 'Dreamcatcher.Controllers.MetaMenu',

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
    $('html, body').animate {scrollTop:0},'slow'
    @currentPanel.showPanel()
    $('#bodyClick').show()

  hideAllPanels: ->
    $('#settingsPanel,#appearancePanel').fadeOut 250
    $('#bodyClick').hide()
    $('.item.settings,.item.appearance').removeClass 'selected'


  '.trigger click': (el) ->
    if el.hasClass 'selected'
      #@hideAllPanels() TODO: hide if selected (funny with change password)
      return
      
    @hideAllPanels()    
    el.addClass 'selected'

    #loads the panel on-the-fly if selected for the first time (otherwise just display)
    elementId = $('.target:first',el.parent()).attr 'id'
    switch elementId
      when "settingsPanel"
        @settingsPanel = new Dreamcatcher.Controllers.Settings $("#settingsPanel") if not @settingsPanel?
        @currentPanel = @settingsPanel
      when "appearancePanel"
        @appearancePanel = new Dreamcatcher.Controllers.Appearance $("#appearancePanel") if not @appearancePanel?
        @currentPanel = @appearancePanel

    @expandSelectedPanel()
