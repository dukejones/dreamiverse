$.Controller 'Dreamcatcher.Controllers.Entries.DreamField', {
  pluginName: 'dreamField'
}, {

  model: {
    entry : Dreamcatcher.Models.Entry
  }
  
  el: {
    bookMatrix: (id) ->
      return $(".matrix.book[data-id=#{id}]", @element) if id?
      return @element
  }

  data: (el) ->
    return el.data type if type?
    return el.data 'id' if el?
    return null
    
  #- constructor
  
  init: (el) ->
    @element = $(el)    
    @publish 'book.drop', $('.matrix.books', @element)
    @publish 'entry.drag', @element
          
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


  'book.drop subscribe': (called, parent) ->
    $('.book, .avatar', parent).each (i, el) =>
      log $(el)
      @publish 'book.close', $(el)
      $(el).droppable {         
        drop: (ev, ui) =>
          dropEl = $(ev.target)
          #log dropEl
          #log ui.draggable
          @moveEntryToBook ui.draggable, dropEl

        over: (ev, ui) =>
          #log ev.target
          
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

  'entry.drag subscribe': (called, parent) ->
    $('.thumb-2d', parent).draggable {
      containment: 'document'
      zIndex: 100
      revert: false
      helper: 'clone'
      revertDuration: 100
      start: (ev, ui) =>
        log 'x'
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
  
  hideEntryField: ->
    $('#entryField').children().hide()
  
  showEntryField: (username) ->
    if @element.data('username') is username
      @hideEntryField()
      $('.book, .thumb-2d', @element).show().css 'opacity',''
      $('.matrix.books, .matrix.index').fadeIn 500
      @publish 'appearance.change'
      return
      
    @model.entry.index username, (html) =>
      @hideEntryField()
      $('.matrix.books').remove()
      @element.replaceWith html
      $('.matrix.books').books() 
      $('.matrix.books, .matrix.index').fadeIn 500
      @publish 'appearance.change'
    
    
  'entries.index subscribe': (called, data) ->
    username = if data.username? then data.username else null
    @publish 'context_panel.show', username
    @showEntryField username
    
}
  
