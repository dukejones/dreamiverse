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
        showEntryEl.linkify().videolink().comments()

  showEntryElement: (entryEl) ->
    $('#showEntry').children().hide()
    $('#entryField').children().hide()
    $('#showEntry').show()
    entryEl.show()
    @publish 'appearance.change', entryEl.data 'viewpreference'
  
  'entry.show subscribe': (called, href) ->
    window.history.pushState null, null, href
    hrefSplit = href.split '/'
    username = hrefSplit[1]
    entryId = hrefSplit[2]
    #@publish 'context_panel.show', username
    @showEntryById entryId

  'a.spine-nav click': (el, ev) ->
    ev.preventDefault()
    @historyAdd
      controller: 'book'
      action: 'show'
      id: el.data 'id'

  '.stream click': (el, ev) ->
    ev.preventDefault()
    @historyAdd {
      controller: 'entry'
      action: 'stream'
    }
    
  '.entries click': (el, ev) ->
    ev.preventDefault()
    @historyAdd {
      controller: 'entry'
      action: 'field'
    }
    
  '.prev, .next click': (el, ev) ->
    ev.preventDefault()
    
  '.editEntry click': (el, ev) ->
    ev.preventDefault()
    @publish 'entry.edit', el.attr 'href'

    
}
  
  
  
