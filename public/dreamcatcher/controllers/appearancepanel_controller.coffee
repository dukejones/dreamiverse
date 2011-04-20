$.Controller('Dreamcatcher.Controllers.AppearancePanel',

  init: ->
    console.log 'created appearance panel'

  load: ->
    Dreamcatcher.Models.AppearancePanel.findAll({}, @callback('show'))

  show: (bedsheets) ->
    $("#bedsheetScroller ul").html(@view('show',{bedsheets: bedsheets}))

  '.bedsheet click': (el) ->
    bedsheetId = el.attr("data-id")
    bedsheetUrl = "url('/images/uploads/#{bedsheetId}-bedsheet.jpg')"
    $('#body').css('background-image', bedsheetUrl)
    @update({ bedsheet_id: bedsheetId, scrolling: null, theme: null})
    
  '#scroll,#fixed click': (el) ->
    scrolling = el.attr('id')
    $('#body').removeClass('fixed scroll').addClass(scrolling)
    @update({ scrolling: scrolling }) 

  '#light,#dark click': (el) ->
    theme = el.attr('id')
    $('#body').removeClass('light dark').addClass(theme)
    @update({ theme: theme }) 

  update: (data) ->
    #entryId is null if user mode
    entryId = null
    entryId = $('#showEntry').data('id') if $('#show_entry_mode').attr('name')?
    Dreamcatcher.Models.AppearancePanel.update(entryId, data)
)

new Dreamcatcher.Controllers.AppearancePanel($("#appearancePanel"))
