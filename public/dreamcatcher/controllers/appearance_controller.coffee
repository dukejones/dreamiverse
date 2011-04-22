$.Controller 'Dreamcatcher.Controllers.Appearance',

  #TODO: fixed, scroll doesn't work when loaded (not selected)

  init: ->
    #sets the entryId if current page is an entry (otherwise null for user view)
    @entryId = $('#showEntry').data('id') if $('#show_entry_mode').attr('name')?
    
    #TODO: get default genre - needs a field in user table.
    #defaultGenre = $('#defaultGenre').data('id')
    #$('#genreSelector').select(defaultGenre)
    #@bedsheets.updateGenre(defaultGenre)

  showPanel: ->
    $('#appearancePanel').show()
    @bedsheets = new Dreamcatcher.Controllers.Bedsheet($('#bedsheetScroller'),{parent: this}) if not @bedsheets?
    
  updateAppearanceModel: (data) ->
    Dreamcatcher.Models.Appearance.update(@entryId, data)    

  '#genreSelector change': (el, ev) ->
    genre = el.val()
    @bedsheets.updateGenre(genre)
    
  '#scroll,#fixed click': (el) ->    
    scrolling = el.attr('id')
    $('#body').removeClass('fixed scroll').addClass(scrolling) 
    @updateAppearanceModel( { scrolling: scrolling } )
    
  '#light,#dark click': (el) ->
    theme = el.attr('id')
    $('#body').removeClass('light dark').addClass(theme)
    @updateAppearanceModel( { theme: theme } )