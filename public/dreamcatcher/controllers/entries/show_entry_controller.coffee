$.Controller 'Dreamcatcher.Controllers.Entries.ShowEntry', {
  pluginName: 'showEntry'
}, {
  
  model: {
    entry : Entry
  }

  el: { 
    entry: (id) ->
      return $("#showEntry .entry[data-id=#{id}]")
  }
  
  init: (el) ->
    @element = el
    @element.tags 'show' # invoke the tags controller
    @activatePlugins $('.entry', @element)
    

  showEntryById: (id) ->
    entryEl = @el.entry id
    if entryEl.exists()
      @showEntryElement entryEl
    else
      @model.entry.show id, (html) =>
        $('#showEntry').append html
        @showEntryElement @el.entry id
        showEntryEl = $('#showEntry .entry:last')
        @activatePlugins showEntryEl
  
  activatePlugins: (el) ->
    el.linkify()
    el.videolink() #check if this is ok... might need to uncomment somewhere else
    $('.lightbox', el).each -> $(this).lightBox {containerResizeSpeed: 0}
    el.comments()
        
  showEntryElement: (entryEl) ->
    @element.siblings().hide()
    @element.fadeIn '500'
    entryEl.show()
    @publish 'appearance.change', entryEl.data 'viewpreference'
  
  'entries.show subscribe': (called, data) ->
    @publish 'context_panel.show', data.username
    @showEntryById data.id
    
  'entries.next subscribe': (called, data) ->
    @model.entry.next data.id, (response) =>
      window.history.replaceState null, null, response.redirect_to
      @publish 'entries.show', {id: response.entry_id, username: response.username}
      
  'entries.previous subscribe': (called, data) ->
    @model.entry.previous data.id, (response) =>
      window.history.replaceState null, null, response.redirect_to
      @publish 'entries.show', {id: response.entry_id, username: response.username}

}
  
  
  
