$.Controller 'Dreamcatcher.Controllers.Appearance',
  #TODO: fixed, scroll doesn't work when loaded (not selected)

  init: ->
    #sets the entryId if current page is an entry
    #otherwise null for user view
    @entryId = $('#showEntry').data('id') if $('#show_entry_mode').attr('name')?

  show: ->
    $('#appearancePanel').show()
    
    #load the bedsheets if object hasn't been created yet
    @bedsheets = new Dreamcatcher.Controllers.Bedsheet($('#bedsheetScroller')) if not @bedsheets?
    @bedsheets.setParent(this)
    
  '#scroll,#fixed click': (el) ->
    scrolling = el.attr('id')
    $('#body').removeClass('fixed scroll').addClass(scrolling)
    @update(
      scrolling: scrolling
    ) 

  '#light,#dark click': (el) ->
    @theme = el.attr('id')
    $('#body').removeClass('light dark').addClass(@theme)
    @update(
      theme: @theme
    ) 

  update: (data) ->
    Dreamcatcher.Models.Appearance.update(@entryId, data)

