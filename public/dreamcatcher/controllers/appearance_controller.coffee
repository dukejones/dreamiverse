$.Controller 'Dreamcatcher.Controllers.Appearance',

  #TODO: fixed, scroll doesn't work when loaded (not selected)
  #TODO: need to add css style - so that we know fixed/scroll/sun/moon is selected

  init: ->
    #sets the entryId if current page is an entry
    #otherwise null for user view
    @entryId = $('#showEntry').data('id') if $('#show_entry_mode').attr('name')?
    @setupDefaults()
    @setupAjaxBinding()

  showPanel: ->
    $('#appearancePanel').show()

    #load the bedsheets if object hasn't been created yet
    if not @bedsheets?
      @bedsheets = new Dreamcatcher.Controllers.Bedsheet($('#bedsheetScroller'),{parent: this})
      @bedsheets.setParent(this)
    
  updateAppearanceModel: (data) ->
    Dreamcatcher.Models.Appearance.update(@entryId, data)    

  #get all defaults (or current), and highlight in UI
  setupDefaults: ->
    @scrolling = if $("#body").hasClass("fixed") then "fixed" else "scroll"
    @highlightScrolling $("#"+@scrolling)
    
    @theme = if $("#body").hasClass("light") then "light" else "dark"
    @highlightTheme $("#"+@theme)
    
  #Highlight the selected button
  highlightScrolling: (el) ->
    $("#fixed,#scroll").removeClass("selected")
    el.addClass("selected") #TODO: style needs to be added
    
  highlightTheme: (el) ->
    $("#light,#dark").removeClass("selected")
    el.addClass("selected") #TODO: style needs to be added


  setupAjaxBinding: ->
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


  '#genreSelector change': (el, ev) ->
    genre = el.val()
    @bedsheets.updateGenre(genre)
    
  '#scroll,#fixed click': (el) ->    
    @scrolling = el.attr('id')
    $('#body').removeClass('fixed scroll').addClass(@scrolling) 
    @highlightScrolling el
    @updateAppearanceModel(
      scrolling: @scrolling
    )
    
  '#light,#dark click': (el) ->
    @theme = el.attr('id')
    $('#body').removeClass('light dark').addClass(@theme)
    @highlightTheme el
    @updateAppearanceModel(
      theme: @theme
    )