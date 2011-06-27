$.Controller 'Dreamcatcher.Controllers.Entries.DreamField', {
  pluginName: 'dreamField'  
}, {
  
  #- constructor
  
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
      # helper: 'clone'
    }
  
  #- entry field
  
  showEntryField: (username, newBook, editBookId, reload) ->
    if (not reload) and ($('.matrix.index', @element).data('username') is username)
      @displayEntryField null, newBook, editBookId
    else
      Entry.index username, (html) =>
        @displayEntryField html, newBook, editBookId
      
  displayEntryField: (html, newBook, editBookId) ->
    # TODO: have a good look at this
    if not html?
      $('#entryField').children().each ->
        $(this).hide() unless $(this).attr('id') is 'entriesIndex'
      $('.matrix.bookIndex', @element).remove()
      @element.children().fadeIn '500' 
    else
      $('#entryField').children().hide()
      @element.html html
      @setupEntryDragging()
      #@publish 'entries.drag', @element
      $('.matrix.books', @element).books()
    
    @publish 'books.create' if newBook
    @publish 'books.modify', editBookId if editBookId?
    
    @element.fadeIn 500 unless @element.is ':visible'
    @publish 'appearance.change'
    
    $('.item.stream').removeClass('selected')
    $('.item.home').addClass('selected')
    
    
  'entries.index subscribe': (called, data) ->
    data ?= {}
    username = data.username ? $('#userInfo').data('username')
    newBook = data.newBook?
    editBook = data.editBook
    reload = data.reload?
    
    @publish 'books.close'
    @publish 'context_panel.show', username
    @showEntryField username, newBook, editBook, reload
    
  'books.new subscribe': ->
    @publish 'entries.index', { newBook: true }
  
  'books.edit subscribe': (called, data) ->
    @publish 'entries.index', { editBook: data.id }
    
}
  
