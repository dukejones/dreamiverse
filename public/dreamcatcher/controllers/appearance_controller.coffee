$.Controller('Dreamcatcher.Controllers.Appearance',

  #id of entry or null for user
  init: ->
    @entryId = $('#showEntry').data('id') if $('#show_entry_mode').attr('name')?

  show: ->
    $('#appearancePanel').show()
    @bedsheets = new Dreamcatcher.Controllers.Bedsheets($('#bedsheetScroller'))
    
  '#scroll,#fixed click': (el) ->
    scrolling = el.attr('id')
    $('#body').removeClass('fixed scroll').addClass(scrolling)
    @update(
      scrolling: scrolling
    ) 

  '#light,#dark click': (el) ->
    theme = el.attr('id')
    $('#body').removeClass('light dark').addClass(theme)
    @update(
      theme: theme
    ) 

  update: (data) ->
    Dreamcatcher.Models.AppearancePanel.update(@entryId, data)
)


