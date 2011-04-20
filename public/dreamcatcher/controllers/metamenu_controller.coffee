$.Controller('Dreamcatcher.Controllers.MetaMenu',
  #id of entry or null for user
  init: ->
    log('init')
    
  load: ->
    @hideAll()
  
  '#bodyClick click': (el) ->
    @hideAll()
  
  '.trigger click': (el) ->
    @hideAll()
    el.addClass('selected')
    id = el.parent().find(".target:first").attr('id')
    
    switch id
      when "settingsPanel"
        if not @settingsPanel 
          @settingsPanel = new Dreamcatcher.Controllers.Settings($("#settingsPanel"))
        @currentPanel = @settingsPanel
      when "appearancePanel"
        if not @appearancePanel 
          @appearancePanel = new Dreamcatcher.Controllers.Appearance($("#appearancePanel"))
        @currentPanel = @appearancePanel
        
    @expand()
    
  expand: () ->
    $('html, body').animate({scrollTop:0}, 'slow') #scroll to top
    @currentPanel.show()

  contract: ->
    # code to contract menu item
    @currentMenu.fadeOut(250) if @currentMenu?
    $('#bodyClick').hide()

  hideAll: ->
    $("#settingsPanel,#appearancePanel").hide()
    $("#bodyClick").hide()
    $('.item.settings,.item.appearance').removeClass('selected')

)
new Dreamcatcher.Controllers.MetaMenu($('.rightPanel'))