$.Controller 'Dreamcatcher.Controllers.Entries.DreamField', {
  pluginName: 'dreamField'  
}, {
  
  init: (el) ->
    @element = $(el)
    @activate()

  activate: ->
    @setupEntryDragging()
    $('.matrix.books', @element).books()

  #- move entry to book (drag & drop)
  setupEntryDragging: ->
    $('.matrix.index .thumb-2d', @element).draggable {
      containment: 'document', zIndex: 100, revert: 'invalid', distance: 15
    }
  
  username: -> $('.matrix.index', @element).data('username')

  #- entry field
  showEntryField: (username, forceReload) ->
    @element.siblings().hide()
    
    if (@username() is username) and not forceReload
      promise = $.Deferred().resolve()
    else
      @publish 'app.loading'
      promise = Entry.index username, (html) =>
        @publish 'app.loading', false
        @element.html html

    promise.done => 
      @show()
      @activate()
      nav = if (dreamcatcher.currentUser().username is @username()) then 'home' else null
      @publish 'navigation.select', nav
      
    return promise

  show: ->
    @element.fadeIn 500 unless @element.is ':visible'
    @publish 'appearance.change'
    
  'entries.index subscribe': (called, data={}) ->
    username = data.username ? dreamcatcher.currentUser().username
    newBook = data.newBook?
    editBookId = data.editBook
    reload = data.reload?
    
    @publish 'books.close'
    @publish 'context_panel.show', username
    
    @showEntryField(username, reload).done (html) =>
      @publish 'books.create' if newBook
      @publish 'books.modify', editBookId if editBookId?
    
}
  
