$.Controller.extend 'Dreamcatcher.Controllers.EntryField.Entries', {
  
  entryModel: Dreamcatcher.Models.Entry
  bookModel: Dreamcatcher.Models.Book
  
  history: (controller, action, id) ->
    @historyAdd {
      controller: controller
      action: action
      id: id
    }
  
  'history.book.new subscribe': (called, data) ->
    @newBook()
    
  'history.entry.new subscribe': (called, data) ->
    @newEntry()
    
  'history.entry.show subscribe': (called, data) ->
    @showEntryById data.id
    
  'history.book.show subscribe': (called, data) ->
    @showBookById data.id
    
  'history.entry.field subscribe': (called, data) ->
    @showField()

    
  '.thumb-2d, .prev, .next click': (el) ->
    @history 'entry', 'show', el.data 'id'

  '.book .mask, .spine click': (el) ->
    @history 'book', 'show', el.closest('.book, .spine').data 'id'
    
  '.stream click': ->
    @history 'entry', 'field'
    

  'drop subscribe': (called, data) ->
    $('.book', data.element).each (i, el) =>
      @books.closeBook $(el)
      $(el).droppable {         
        drop: (ev, ui) =>
          isContext = data.element.attr('id') is 'contextPanel'
          dropEl = null
          dropEl = $(ev.target) if not isContext
          @books.addEntryToBook ui.draggable, dropEl

        over: (ev, ui) =>
          bookEl = $(ev.target)
          @books.openBook bookEl
          $('.entryDrop-active', bookEl).show()

        out: (ev, ui) =>
          bookEl = $(ev.target)
          @books.closeBook bookEl
          $('.entryDrop-active', bookEl).hide()

      }
      
  'drag subscribe': (called, data) ->
    log data.element
    $('.thumb-2d', data.element).draggable {
      containment: 'document'
      zIndex: 100
      revert: true
      revertDuration: 100
      start: (ev, ui) ->
        $('.add-active', ev.target).show()
      stop: (ev, ui) ->
        $('.add-active', ev.target).hide()
    }

  
  init: ->
    @books = new Dreamcatcher.Controllers.EntryField.Books $('#entryField .matrix.books')
    @publish 'drop', { element: $('#entryField .matrix.books') }
    @publish 'drag', { element: $('#entryField .matrix.field') }
      
  closeEverythingOpen: ->
    @books.closeAllBooks()
    
  hideAllEntries: ->
    $('#entryField').children().hide()

  showField: ->
    @hideAllEntries()
    $('#contextPanel .book').remove()
    $('#entryField .matrix.field, #entryField .matrix.books').show()
    

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
      
    @publish 'drop', { element: $('#contextPanel') }
    #$('#contextPanel .avatar').hide()
    @bookModel.show bookId, {}, @callback('showBookEntries', bookId)
    
  showBookEntries: (bookId, html) ->
    $('#entryField').children().hide()
    bookFieldEl = $("#entryField .matrix.book[data-id=#{bookId}]")
    if bookFieldEl.exists()
      bookFieldEl.replaceWith html
    else
      $('#entryField').append html
    
    @publish 'drag', { element: $("#entryField .matrix.book[data-id=#{bookId}]") }
      
    

    
  newBook: ->
    @bookModel.new {}, @callback('showBookThumbHtml')
  
  showBookThumbHtml: (html) ->
    $('#welcomePanel').hide()
    $('#entryField .matrix.books').prepend html
    bookEl = $('#entryField .matrix.books .book:first')
    @books.openBook bookEl
    @publish 'dom', {element: bookEl}
    
  newEntry: ->
    # TODO: if new already showing, just bring up
    @entryModel.new {}, @callback('showNewEntry')

  showNewEntry: (html) ->
    $('#entryField').children().hide()
    if $('#new_entry').exists()
      $('#new_entry').replaceWith html
    else
      $('#entryField').prepend html
    $('#new_entry').show()
    @publish 'dom', { element: $('#new_entry') }
    
}

