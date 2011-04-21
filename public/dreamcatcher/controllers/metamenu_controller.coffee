$.Controller 'Dreamcatcher.Controllers.MetaMenu',

  init: ->
    @setupiOSfix()
    @hideAllPanels()
    
  # iOS Device Fix
  # Checks if the UserAgent is a iOS device
  setupiOSfix: ->
    clickEvent = if (navigator.userAgent.match(/iPad/i)) then "touchstart" else "click"
    # ipad doubleclick remover for left panel
    $('.leftPanel a').bind( clickEvent, (ev)->
      ev.preventDefault()
      window.location = $(ev.currentTarget).attr('href')
    )

  expandSelectedPanel: () ->
    $('html, body').animate({scrollTop:0}, 'slow') #scroll to top
    @currentPanel.showPanel()
    $('#bodyClick').show()

  contractSelectedPanel: ->
    @currentPanel.fadeOut(250) if @currentPanel?
    $('#bodyClick').hide()

  hideAllPanels: ->
    $("#settingsPanel,#appearancePanel").hide()
    $("#bodyClick").hide()
    $('.item.settings,.item.appearance').removeClass('selected')


  '.trigger click': (el) ->
    return if el.hasClass 'selected'
    
    @hideAllPanels()
    el.addClass('selected')

    elementId = el.parent().find(".target:first").attr('id')

    #loads the panel on-the-fly if selected for the first time (otherwise display)
    switch elementId
      when "settingsPanel"
        @settingsPanel = new Dreamcatcher.Controllers.Settings($("#settingsPanel")) if not @settingsPanel?
        @currentPanel = @settingsPanel
      when "appearancePanel"
        @appearancePanel = new Dreamcatcher.Controllers.Appearance($("#appearancePanel")) if not @appearancePanel?
        @currentPanel = @appearancePanel

    @expandSelectedPanel()
