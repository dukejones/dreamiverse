$.Controller.extend 'Dreamcatcher.Controllers.EntryField.Entries', {

  model: {
    entry : Dreamcatcher.Models.Entry
    book : Dreamcatcher.Models.Book
  }
  
  el: {
    bookField: (id) ->
      return $("#entryField .matrix.book[data-id=#{id}]")
    book: (id) ->
      return $("#entryField .matrix.books .book[data-id=#{id}]")
    entry: (id) ->
      return $("#entryField .entry[data-id=#{id}]")
  }
  
  data: (el) ->
    return el.data type if type?
    return el.data 'id' if el?
    return null
    
  #- constructor
  
  init: ->
    @books = new Dreamcatcher.Controllers.EntryField.Books $('#entryField .matrix.books')
    @publish 'drop', { el: $('#entryField .matrix.books') }
    @publish 'drag', { el: $('#entryField .matrix.field') }
    
  #- history
  
  history: (controller, action, id) ->
    params = {
      controller: controller
      action: action
    }
    $.extend params, {id: id} if id?
    @historyAdd params
    
  'history subscribe': (called, data) ->
    @history 'book', 'show', @data bookEl
  
  '.thumb-2d, .prev, .next click': (el) ->
    @history 'entry', 'show', @data el
  
  '.stream click': ->
    @history 'entry', 'field'
    
  #- move entry to book (drag & drop)

  moveEntryToBook: (entryEl, bookEl) ->
    entryId = @data entryEl
    bookId = @data bookEl
    entryMeta = {book_id: bookId}

    @model.entry.update entryId, {entry: entryMeta}, =>
      @closeBook bookEl
      entryEl.appendTo @el.bookMatrix bookEl

    $('.entryDrop-active', bookEl).hide()

  'drop subscribe': (called, data) ->
    $('.book', data.el).each (i, el) =>
      @books.closeBook $(el)
      $(el).droppable {         
        drop: (ev, ui) =>
          dropEl = null
          dropEl = $(ev.target) if data.el.closest('#contextPanel')?
          @books.moveEntryToBook ui.draggable, dropEl

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
    $('.thumb-2d', data.el).draggable {
      containment: 'document'
      zIndex: 100
      revert: true
      revertDuration: 100
      start: (ev, ui) ->
        $('.add-active', ev.target).show()
      stop: (ev, ui) ->
        $('.add-active', ev.target).hide()
    }
       
  #- entry field
  
  #-- hide
  
  hideEntryField: ->
    $('#entryField').children().fadeOut 1000
  
  #-- show
  
  showEntryField: ->
    @hideEntryField()
    $('#contextPanel .book').remove()
    $('#entryField .matrix.field, #entryField .matrix.books').show()
  
  'history.entry.field subscribe': (called, data) ->
    @showEntryField()
    
  #- new entry
    
  newEntry: ->
    # TODO: if new already showing, just bring up
    @model.entry.new {}, (html) =>
      $('#entryField').children().hide()
      if $('#new_entry').exists()
        $('#new_entry').replaceWith html
      else
        $('#entryField').prepend html
      $('#new_entry').show()
      @publish 'dom', { el: $('#new_entry') }
  
  'history.entry.new subscribe': (called, data) ->
    @newEntry()
  
  #- show entry
  
  showEntry: (id) ->
    entryEl = @el.entry id 
    if entryEl.exists()
      @hideEntryField()
      entryEl.show()
    else
      @model.entry.show {id: id}, (html) =>
        @hideEntryField()
        $('#entryField').append html
  
  'history.entry.show subscribe': (called, data) ->
    @showEntry data.id
    
}