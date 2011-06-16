$.Controller 'Dreamcatcher.Controllers.Entries.DreamField', {
  pluginName: 'dreamField'
}, {

  model: {
    entry : Dreamcatcher.Models.Entry
  }
  
  el: {
    bookMatrix: (id) ->
      return $("#entryField .matrix.book[data-id=#{id}]") if id?
      return $("#entryField .matrix.field")
    book: (id) ->
      return $("#entryField .matrix.books .book[data-id=#{id}]")
  }

  data: (el) ->
    return el.data type if type?
    return el.data 'id' if el?
    return null
    
  #- constructor
  
  init: ->
    $('#showEntry').showEntry()
    $('#newEditEntry').newEditEntry()
    $('#entryField .matrix.books').books()
    $('#totem').contextPanel()
    
    @publish 'book.drop', $('#entryField .matrix.books')
    @publish 'entry.drag', $('#entryField .matrix.field')
          
  #- move entry to book (drag & drop)

  moveEntryToBook: (entryEl, bookEl) ->
    entryId = @data entryEl
    bookId = @data bookEl
    bookId = null if bookEl.parent().attr('id') is 'contextPanel'
    entryMeta = {book_id: bookId}

    @model.entry.update entryId, {entry: entryMeta}

    @publish 'book.close', bookEl
    bookMatrixEl = @el.bookMatrix bookId
    if bookMatrixEl.exists()
      entryEl.appendTo bookMatrixEl
    else
      entryEl.hide()
      
    $('.entryDrop-active', bookEl).hide()


  'book.drop subscribe': (called, data) ->
    parentEl = data
    $('.book, .avatar', parentEl).each (i, el) =>
      @publish 'book.close', $(el)
      $(el).droppable {         
        drop: (ev, ui) =>
          dropEl = $(ev.target)
          @moveEntryToBook ui.draggable, dropEl

        over: (ev, ui) =>
          el = $(ev.target)
          @publish 'book.open', el if el.hasClass 'book'
          $('.add-active', ui.helper).show()
          $('.entryDrop-active, .entryRemove', el).show()

        out: (ev, ui) =>
          el = $(ev.target)
          @publish 'book.close', el if el.hasClass 'book' 
          $('.add-active', ui.helper).hide()
          $('.entryDrop-active, .entryRemove', el).hide()
      }

  'entry.drag subscribe': (called, data) ->
    parentEl = data.el
    $('.thumb-2d', parentEl).draggable {
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
    if not $('#entryField .matrix.field').is ':visible'
      $('#contextPanel .book').toggle not start
      $('#contextPanel .avatar').toggle start
  
  #- entry field
  
  hideEntryField: ->
    $('#entryField').children().hide()
  
  showEntryField: ->
    $('#contextPanel .avatar').show()
    $('#contextPanel .book').remove()
    if $('#entryField .matrix.field').exists()
      @hideEntryField()
      $('#entryField .matrix.field, #entryField .matrix.books').show()
    else
      @model.entry.showField {}, (html) =>
        @hideEntryField()
        $('#entryField').append html
    @publish 'appearance.change'
    
    
  'entries.index subscribe': (called, username) ->
    @publish 'context_panel.show', username
    @showEntryField()
    
}
  
