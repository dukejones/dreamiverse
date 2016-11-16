$.Controller 'Dreamcatcher.Controllers.Entries.ShowEntry', {
  pluginName: 'showEntry'
}, {

  init: (el) ->
    @element = $(el)
    @element.tags 'show' # invoke the tags controller
    @activatePlugins $('.entry', @element)    

  showEntryById: (id) ->
    entryEl = $("#showEntry .entry[data-id=#{id}]")
    if entryEl.exists()
      @showEntryElement entryEl
    else
      @publish 'app.loading'
      Entry.show id, (html) =>
        @publish 'app.loading', false
        $('#showEntry').append html
        entryEl = $('#showEntry .entry:last')
        @showEntryElement entryEl
        @activatePlugins entryEl
  
  activatePlugins: (el) ->
    el.linkify()
    el.videolink() #check if this is ok... might need to uncomment somewhere else
    $('.lightbox a', el).each -> $(this).lightBox {containerResizeSpeed: 0}
    el.comments()
        
  showEntryElement: (entryEl) ->
    @element.siblings().hide()
    @element.children().hide()
    entryEl.show()
    @element.fadeIn '500'
    @publish 'appearance.change', entryEl.data 'viewpreference'
  
  'entries.show subscribe': (called, data) ->
    @publish 'context_panel.show', data.username
    @showEntryById data.id
    
  'entries.next subscribe': (called, data) ->
    @publish 'app.loading'
    Entry.next data.id, (response) =>
      @publish 'app.loading', false
      window.history.replaceState null, null, response.redirect_to
      @publish 'entries.show', {id: response.entry_id, username: response.username}
      
  'entries.previous subscribe': (called, data) ->
    @publish 'app.loading'
    Entry.previous data.id, (response) =>
      @publish 'app.loading', false
      window.history.replaceState null, null, response.redirect_to
      @publish 'entries.show', {id: response.entry_id, username: response.username}

}
  
  
  
