$.Controller 'Dreamcatcher.Controllers.Entries.DreamField', {
  pluginName: 'dreamField'  
}, {
  
  init: (el) ->
    @element = $(el)
    $('.matrix.books', @element).books()
    @setupEntryDragging()

  #- move entry to book (drag & drop)
  setupEntryDragging: ->
    $('.matrix.index .thumb-2d', @element).draggable {
      containment: 'document'
      zIndex: 100
      revert: 'invalid'
      distance: 15
    }
  
  username: ->
    $('.matrix.index', @element).data('username')

  #- entry field
  showEntryField: (username, forceReload) ->
    # if (not forceReload) and (@username is username)
    #   # Hide everything within #entryField
    #   $('#entryField').children().each ->
    #     $(this).hide()
    #   # $('.matrix.bookIndex', @element).remove()
    #   # @element.children().fadeIn '500' 
    #   # @displayEntryField null, newBook, editBookId
    #   $.Deferred().resolve()
    # 
    # else

    @element.siblings().hide()
    @publish 'app.loading'
    Entry.index username, (html) =>
      @publish 'app.loading', false
      @element.html html
      @setupEntryDragging()
      $('.matrix.books', @element).books()
      @element.fadeIn 500 unless @element.is ':visible'
      @publish 'appearance.change'
      
      
  displayEntryField: (html, newBook, editBookId) ->
    
    # @publish 'books.create' if newBook
    # @publish 'books.modify', editBookId if editBookId?
    # 
    # 
    # $('.item.stream').removeClass('selected')
    # $('.item.home').addClass('selected')
    
    
  'entries.index subscribe': (called, data={}) ->
    username = data.username ? $('#currentUserInfo').data('username')
    newBook = data.newBook?
    editBookId = data.editBook
    reload = data.reload?
    
    @publish 'books.close'
    @publish 'context_panel.show', username
    
    # @showEntryField username, newBook, editBookId, reload
    @showEntryField(username, reload).then (html) =>
      @publish 'books.create' if newBook
      @publish 'books.modify', editBookId if editBookId?

    
}
  
