$.Controller 'Dreamcatcher.Controllers.Appearance',

  #TODO: fixed, scroll doesn't work when loaded (not selected)
  #TODO: need to add css style - so that we know fixed/scroll/sun/moon is selected

  init: ->
    #sets the entryId if current page is an entry
    #otherwise null for user view
    @entryId = $('#showEntry').data('id') if $('#show_entry_mode').attr('name')?

  show: ->
    #get scrolling and theme from pageElement - check with Duke if this is done correctly
    @scrolling = if $("#body").hasClass("fixed") then "fixed" else "scroll"
    @highlightScrolling $("#"+@scrolling)
    
    @theme = if $("#body").hasClass("light") then "light" else "dark"
    @highlightTheme $("#"+@theme)
    
    $('#appearancePanel').show()

    #load the bedsheets if object hasn't been created yet
    @bedsheets = new Dreamcatcher.Controllers.Bedsheet($('#bedsheetScroller')) if not @bedsheets?
    @bedsheets.setParent(this)
    alert 'x'
    
  update: (data) ->
    Dreamcatcher.Models.Appearance.update(@entryId, data)

    
  #Highlights the right buttons
  highlightScrolling: (el) ->
    $("#fixed,#scroll").removeClass("selected")
    el.addClass("selected") #TODO: style needs to be added
    
  highlightTheme: (el) ->
    $("#light,#dark").removeClass("selected")
    el.addClass("selected") #TODO: style needs to be added

  '#genreSelector change': (el, ev) ->
    genre = el.val()
    @bedsheets.updateGenre(genre)
    
  '#scroll,#fixed click': (el) ->    
    @scrolling = el.attr('id')
    
    $('#body').removeClass('fixed scroll').addClass(@scrolling) 
    @highlightScrolling el
    
    @update(
      scrolling: @scrolling
    )
    
  '#light,#dark click': (el) ->
    @theme = el.attr('id')
    
    $('#body').removeClass('light dark').addClass(@theme)
    @highlightTheme el
    
    @update(
      theme: @theme
    )

