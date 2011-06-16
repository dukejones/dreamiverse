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

  showEntryById: (id) ->
    entryEl = @el.entry id
    log 'showEntryById'
    $('#showEntry').tags 'show' # invoke the tags controller
    if entryEl.exists()
      @showEntryElement entryEl
    else
      @model.entry.show {id: id}, (html) =>
        $('#showEntry').append html
        @showEntryElement @el.entry id
        showEntryEl = $('#showEntry .entry:last')
        showEntryEl.linkify().videolink()
        showEntryEl.comments()

  showEntryElement: (entryEl) ->
    $('#showEntry').children().hide()
    $('#entryField').children().hide()
    $('#showEntry').show()
    entryEl.show()
    @publish 'appearance.change', entryEl.data 'viewpreference'
  
  'entries.show subscribe': (called, id) ->
    @publish 'context_panel.show'#, username
    @showEntryById id

}
  
  
  
