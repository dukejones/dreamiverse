$.Controller.extend 'Dreamcatcher.Controllers.EntryField.Entries', {
  
  models: Dreamcatcher.Models.Entry
  bookModel: Dreamcatcher.Models.Book
  
  'history.book.new subscribe': (called, data) ->
    
    
  'history.entry.show subscribe': (called, data) ->
    @showEntryById data.id
    
  'history.book.show subscribe': (called, data) ->
    @books.showBookById data.id
  
  
  init: ->
    alert 'x'
    @books = new Dreamcatcher.Controllers.Entries.Books $('#entryField .matrix')
      
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
      @model.getHtml { id: entryId }, @callback('showEntryHtml')

  showEntryHtml: (html) ->
    @hideAllEntries()
    $('#entryField').append html
    #@bindAjaxLinks '#entryField .entry:last'
    


  showBookById: (bookId) ->
    @model.show bookId, {}, @callback('showBookHtml')
    
  showBookHtml: (html) ->
    $('#entryField').children().hide()
    $('#entryField').append html
    $('#contextPanel').prepend $("#entryField .book[data-id=#{bookId}]").clone()
    
  newBook: ->
    @bookModel.new {}, @callback('showBookThumbHtml')
  
  showBookThumbHtml: (html) ->
    $('#entryField .matrix').prepend html
    bookEl = $('#entryField .matrix .book:first')
    @openBook bookEl
    
}

