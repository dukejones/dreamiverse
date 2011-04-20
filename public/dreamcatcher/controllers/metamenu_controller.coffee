$.Controller('Dreamcatcher.Controllers.MetaMenu',

  init: ->
    log 'init MetaMenu'

  load: ->
    @hideAll()

  '.trigger click': (el) ->
    @hideAll()
    el.addClass('selected')
    
    elementId = el.parent().find(".target:first").attr('id')

    #loads the new panel on-the-fly only once selected for the first time
    #otherwise it simple shows the panel
    #this is useful, particularly for the appearance panel, as we don't want the bedsheets to load until it's selected.
    switch elementId
      when "settingsPanel"
        @settingsPanel = new Dreamcatcher.Controllers.Settings($("#settingsPanel")) if not @settingsPanel?
        @currentPanel = @settingsPanel
      when "appearancePanel"
        @appearancePanel = new Dreamcatcher.Controllers.Appearance($("#appearancePanel")) if not @appearancePanel?
        @currentPanel = @appearancePanel
        
    @expand()
    
  #Expands the current selected item
  expand: () ->
    $('html, body').animate({scrollTop:0}, 'slow') #scroll to top
    @currentPanel.show()
    $('#bodyClick').show()

  #Contracts currentMenu item
  contract: ->
    @currentMenu.fadeOut(250) if @currentMenu?
    $('#bodyClick').hide()

  #Hides all items and unselects buttons (including bodyClick)
  hideAll: ->
    $("#settingsPanel,#appearancePanel").hide()
    $("#bodyClick").hide()
    $('.item.settings,.item.appearance').removeClass('selected')

)
