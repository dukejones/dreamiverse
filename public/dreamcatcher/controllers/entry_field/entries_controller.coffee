$.Controller.extend 'Dreamcatcher.Controllers.EntryField.Entries', {
  
  entryModel: Dreamcatcher.Models.Entry
  bookModel: Dreamcatcher.Models.Book
  
  
  'history.book.new subscribe': (called, data) ->
    @newBook()
    
  'history.entry.new subscribe': (called, data) ->
    @newEntry()
    
  'history.entry.show subscribe': (called, data) ->
    @showEntryById data.id
    
  'history.book.show subscribe': (called, data) ->
    @showBookById data.id
    
  'history subscribe': (called, data) ->
    alert 'x'

  
  init: ->
    @books = new Dreamcatcher.Controllers.EntryField.Books $('#entryField .matrix')
      
  closeEverythingOpen: ->
    @books.closeAllBooks()

  newBook: ->
    @books.newBook()
      
  '.thumb-2d click': (el) ->
    @historyAdd {
      controller: 'entry'
      action: 'show'
      id: el.data 'id'
    }
    
  '.book dblclick': (el) ->
    @historyAdd {
      controller: 'book'
      action: 'show'
      id: el.data 'id'
    }
    
    
  hideAllEntries: ->
    $('#entryField').children().hide()

  showMatrix: ->
    @hideAllEntries()
    $('#entryField .matrix').show()
    $('#entryField .thumb-2d').fadeIn()
    

  showEntryById: (entryId) ->
    entryEl = $(".entry[data-id=#{entryId}]")
    if entryEl.exists()
      @hideAllEntries()
      entryEl.show()
    else
      @entryModel.show { id: entryId }, @callback('showEntryHtml')

  showEntryHtml: (html) ->
    @hideAllEntries()
    $('#entryField').append html
    

  showBookById: (bookId) ->
    bookHtml = $("#entryField .book[data-id=#{bookId}]").clone().css 'z-index', 2000
    if $('#contextPanel .book').exists()
      $('#contextPanel .book').replaceWith bookHtml
    else
      $('#contextPanel').prepend bookHtml
    #$('#contextPanel .avatar').hide()
    @bookModel.show bookId, {}, @callback('showBookEntries')
    
  showBookEntries: (html) ->
    $('#entryField').children().hide()
    $('#entryField').append html
    
  newBook: ->
    @bookModel.new {}, @callback('showBookThumbHtml')
  
  showBookThumbHtml: (html) ->
    $('#entryField .matrix').prepend html
    bookEl = $('#entryField .matrix .book:first')
    @books.openBook bookEl
    @publish 'dom', {element: bookEl}
    
  newEntry: ->
    @entryModel.new {}, @callback('showNewEntry')

  showNewEntry: (html) ->
    $('#entryField').children().hide()
    if $('#new_entry').exists()
      $('#new_entry').replaceWith html
    else
      $('#entryField').prepend html
    $('#new_entry').show()
    @publish 'dom', {element: $('#new_entry')}
}

