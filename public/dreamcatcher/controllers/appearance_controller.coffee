$.Controller 'Dreamcatcher.Controllers.Appearance',

  #TODO: entryId doesn't actually work on new/edit mode.

  init: ->
    #sets the entryId if current page is an entry (otherwise null for user view)
    @entryId = $('#showEntry').data 'id' if $('#showEntry')?#if $('#show_entry_mode').attr 'name'?
    @defaultGenre = $('#defaultGenre').val()

  showPanel: ->
    $('#appearancePanel').show()
    if not @bedsheets?
      @bedsheets = new Dreamcatcher.Controllers.Bedsheet $('#bedsheetScroller'),{parent: this}
      if @defaultGenre?
        $('#genreSelector').select @defaultGenre
        @bedsheets.loadGenre @defaultGenre

  updateAppearanceModel: (data) ->
    Dreamcatcher.Models.Appearance.update @entryId,data

  '#genreSelector change': (el, ev) ->
    genre = el.val()
    @bedsheets.loadGenre genre
    @updateAppearanceModel {default_genre: genre}
    
  '#scroll,#fixed click': (el) ->    
    scrolling = el.attr 'id'
    $('#body').removeClass('fixed scroll').addClass scrolling
    @updateAppearanceModel {scrolling: scrolling}
    
  '#light,#dark click': (el) ->
    theme = el.attr 'id'
    $('#body').removeClass('light dark').addClass theme
    @updateAppearanceModel {theme: theme}