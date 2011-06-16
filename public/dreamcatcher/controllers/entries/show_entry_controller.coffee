$.Controller 'Dreamcatcher.Controllers.Entries.ShowEntry', {
  pluginName: 'showEntry'
}, {
  
  model: {
    entry : Dreamcatcher.Models.Entry
  }

  el: { 
    entry: (id) ->
      return $("#showEntry .entry[data-id=#{id}]")
  }
  
  init: (el) ->
    @element = $(el)
    @element.tags 'show' # invoke the tags controller

  showEntryById: (id) ->
    entryEl = @el.entry id
    if entryEl.exists()
      @showEntryElement entryEl
    else
      @model.entry.show id, (html) =>
        $('#showEntry').append html
        @showEntryElement @el.entry id
        showEntryEl = $('#showEntry .entry:last')
        showEntryEl.linkify().videolink()
        showEntryEl.comments()

  showEntryElement: (entryEl) ->
    $('#showEntry').children().hide()
    $('#entryField').children().hide()
    $('#showEntry').fadeIn '500'
    entryEl.show()
    @publish 'appearance.change', entryEl.data 'viewpreference'
  
  'entries.show subscribe': (called, data) ->
    @publish 'context_panel.show', data.username
    @showEntryById data.id

}
  
  
  
