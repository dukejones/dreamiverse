$.Controller 'Dreamcatcher.Controllers.Entries.DreamField', {
  
  pluginName: 'dreamField'  
}, {

  model: {
    entry : Dreamcatcher.Models.Entry
  }
  
  data: (el) ->
    return el.data type if type?
    return el.data 'id' if el?
    return null
    
  #- constructor
  
  init: (el) ->
    @element = $(el)
    $('.matrix.books', @element).books()
    @publish 'entries.drag', @element
          
  #- move entry to book (drag & drop)
  
  'entries.drag subscribe': (called, parent) ->
    log parent
    $('.thumb-2d', parent).draggable {
      containment: 'document'
      zIndex: 100
      revert: false
      helper: 'clone'
      revertDuration: 100
      start: (ev, ui) =>
        @toggleBookContext true
      stop: (ev, ui) =>
        @toggleBookContext false
        
    }
  
  #- hides the book if it sits in the context menu
  
  toggleBookContext: (start) ->
    unless @element.is ':visible'
      $('#contextPanel .book').toggle not start
      $('#contextPanel .avatar').toggle start
  
  #- entry field
  
  showEntryField: (username, newBook) ->
    if $('.matrix.index',@element).data('username') is username
      @displayEntryField null, newBook
      return
    @model.entry.index username, (html) =>
      @displayEntryField html, newBook
      
  displayEntryField: (html, newBook, editBookId) ->
    $('#entryField').children().each ->
      $(this).hide() if $(this) isnt @element
    @element.children().show()
    $('.matrix.bookIndex',@element).hide()
    if html?
      @element.html html
      $('.matrix.books', @element).books()
    @publish 'books.create' if newBook
    @publish 'books.modify', editBookId if editBookId?
    @element.fadeIn 500
    @publish 'appearance.change'
    
    $('.item.stream').removeClass('selected')
    $('.item.home').addClass('selected')
    
    
  'entries.index subscribe': (called, data) ->
    username = if data? and data.username? then data.username else $('#userInfo').data 'username'
    newBook = if data? and data.newBook? then data.newBook else false
    editBook = data.editBook if data? and data.editBook?
    @publish 'context_panel.show', username
    @showEntryField username, newBook
    
  'books.new subscribe': ->
    @publish 'entries.index', { newBook: true }
  
  'books.edit subscribe': (called, data) ->
    @publish 'entries.index', { editBook: data.id }
    
}
  
