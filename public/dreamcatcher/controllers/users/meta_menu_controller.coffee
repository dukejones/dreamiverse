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
  
  'body.clicked subscribe': (data) ->
    @hideAllPanels()
    
    
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
    
  'menu.show subscribe': (data) ->
    @selectPanel data

  '.item.settings,.item.appearance click': (el) ->
    expanded = el.hasClass('selected')
    @hideAllPanels()
    return if expanded
    panelName = $('.target:first',el.parent()).attr('id').replace('Panel','')
    @selectPanel panelName
    

  #- entry field / stream
  # todo: remove and replace
    
  '.item.stream2 click': (el) ->
    @historyAdd {
      controller: 'entry'
      action: 'stream'
    }

  '.item.home2 click': (el) ->
    @historyAdd {
      controller: 'entry'
      action: 'field'
    }
    
    
  '#new-post change': (el) ->
    #todo: fix so empty is never showing (style)
    if el.val() isnt 'empty'
      @historyAdd {
        controller: el.val()
        action: 'new'
      }
    el.val 'empty'
    
  '.newEntry click': (el) ->
    @historyAdd {
      controller: 'entry'
      action: 'new'
    }
    

