$.Controller 'Dreamcatcher.Controllers.Entries.DreamField', {
  pluginName: 'dreamField'  
}, {
  
  init: (el) ->
    @element = $(el)
    @activate()

  activate: ->
    @setupEntryDragging() 
    $('.book', @element).each (i, el) => $(el).books(this) unless $(el).hasClass 'dreamcatcher_entries_books'

  setupEntryDragging: ->
    $('.matrix.index .thumb-2d', @element).draggable {
      containment: 'document', zIndex: 100, revert: 'invalid', distance: 15
    }
  
  username: -> $('.matrix.index', @element).data('username')

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
      nav = if (DC.currentUser().username is @username()) then 'home' else null
      @publish 'navigation.select', nav
      
    return promise

  show: ->
    $('.matrix.bookIndex', @element).remove()
    el = $(".matrix.index, .matrix.books", @element)
    el.fadeIn 500 unless el.is ':visible'
    @element.fadeIn()
    @publish 'appearance.change'
    #TODO: contextPanel
    
  'entries.index subscribe': (called, data={}) ->
    username = data.username ? DC.currentUser().username
    @publish 'books.close'
    @publish 'context_panel.show', username
    @showEntryField username

  'books.new subscribe': ->
    Book.new {}, (html) =>
      $('#welcomePanel').hide()
      @element.prepend html
      $('.book:first', @element).books this, true
    
}
  
