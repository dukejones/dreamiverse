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
      
  displayEntryField: (html, newBook) ->
    $('#entryField').children().hide()
    if html?
      @element.html html
      $('.matrix.books', @element).books()
    @publish 'books.create' if newBook
    @element.fadeIn 500
    @publish 'appearance.change'
    
    
  'entries.index subscribe': (called, data) ->
    username = if data? and data.username? then data.username else $('#userInfo').data 'username'
    newBook = if data? and data.newBook? then data.newBook else false
    @publish 'context_panel.show', username
    @showEntryField username, newBook
    
  'books.new subscribe': ->
    @publish 'entries.index', { newBook: true }
    
}
  
