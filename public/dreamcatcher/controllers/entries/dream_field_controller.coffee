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
      revert: false
      helper: 'clone'
    }
  
  #- entry field
  
  showEntryField: (username, newBook, editBookId) ->
    if $('.matrix.index', @element).data('username') is username
      @displayEntryField null, newBook, editBookId
      return
    Dreamcatcher.Models.Entry.index username, (html) =>
      @displayEntryField html, newBook, editBookId
      
  displayEntryField: (html, newBook, editBookId) ->
    # TODO: have a good look at this
    if not html?
      $('#entryField').children().each ->
        $(this).hide() unless $(this).attr('id') is 'entriesIndex'
      $('.matrix.bookIndex', @element).remove()
      @element.children().fadeIn '500' 
    if html?
      $('#entryField').children().hide()
      @element.html html
      @publish 'entries.drag', @element
      $('.matrix.books', @element).books()
    
    @publish 'books.create' if newBook
    @publish 'books.modify', editBookId if editBookId?
    
    @element.fadeIn 500 unless @element.is ':visible'
    @publish 'appearance.change'
    
    $('.item.stream').removeClass('selected')
    $('.item.home').addClass('selected')
    
    
  'entries.index subscribe': (called, data) ->
    username = if data? and data.username? then data.username else $('#userInfo').data 'username'
    newBook = if data? and data.newBook? then data.newBook else false
    editBook = data.editBook if data? and data.editBook?
    @publish 'context_panel.show', username
    @showEntryField username, newBook, editBook
    
  'books.new subscribe': ->
    @publish 'entries.index', { newBook: true }
  
  'books.edit subscribe': (called, data) ->
    @publish 'entries.index', { editBook: data.id }
    
}
  
