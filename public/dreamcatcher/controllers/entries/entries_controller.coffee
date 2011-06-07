$.Controller.extend 'Dreamcatcher.Controllers.Entries', {

  #use across all controllers
  model: {
    entry : Dreamcatcher.Models.Entry
    book : Dreamcatcher.Models.Book
  }
  
  el: {
    bookMatrix: (id) ->
      return $("#entryField .matrix.book[data-id=#{id}]") if id?
      return $("#entryField .matrix.field")
    book: (id) ->
      return $("#entryField .matrix.books .book[data-id=#{id}]")
    entry: (id) ->
      return $("#showEntry .entry[data-id=#{id}]")
  }

  data: (el) ->
    return el.data type if type?
    return el.data 'id' if el?
    return null
    
  #- constructor
  
  init: ->
    @show = new Dreamcatcher.Controllers.Entries.Show $('#showEntry') if $('#showEntry').exists() # todo: #showEntry
    @books = new Dreamcatcher.Controllers.Entries.Books $('#entryField .matrix.books') if $('#entryField .matrix.books').exists()
    if $('#entryField .matrix').exists()
      @historyAdd {
        controller: 'entry'
        action: 'field'
      }
    @publish 'drop', $('#entryField .matrix.books')
    @publish 'drag', $('#entryField .matrix.field')
          
  #- move entry to book (drag & drop)

  moveEntryToBook: (entryEl, bookEl) ->
    entryId = @data entryEl
    bookId = @data bookEl
    bookId = null if bookEl.parent().attr('id') is 'contextPanel'
    entryMeta = {book_id: bookId}

    @model.entry.update entryId, {entry: entryMeta}

    #could move back if error
    @books.closeBook bookEl
    bookMatrixEl = @el.bookMatrix bookId
    if bookMatrixEl.exists()
      entryEl.appendTo bookMatrixEl
    else
      entryEl.hide()
      
    $('.entryDrop-active', bookEl).hide()

  'drop subscribe': (called, data) ->
    parentEl = data
    $('.book', parentEl).each (i, el) =>
      @books.closeBook $(el)
      $(el).droppable {         
        drop: (ev, ui) =>
          dropEl = null
          dropEl = $(ev.target)
          @moveEntryToBook ui.draggable, dropEl

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
    parentEl = data.el
    $('.thumb-2d', parentEl).draggable {
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
    $('#entryField').children().hide()#fadeOut 'fast'
  
  #-- show
  
  showEntryField: ->
    @hideEntryField()
    $('#contextPanel .avatar').show()
    $('#contextPanel .book').remove()
    $('#entryField .matrix.field, #entryField .matrix.books').show()
    
    bedsheetId = $('#entryField').data 'imageid'
    @publish 'bedsheet.change', bedsheetId if bedsheetId?
  
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
      
      @new = new Dreamcatcher.Controllers.Entries.New $('#new_entry')
      
      @publish 'dom', $('#new_entry')
  
  'history.entry.new subscribe': (called, data) ->
    @newEntry()
  
  #- show entry
  
  showEntryById: (id) ->
    entryEl = @el.entry id
    if entryEl.exists()
      @showEntryElement entryEl
    else
      @model.entry.show {id: id}, (html) =>
        $('#showEntry').append html
        @showEntryElement @el.entry id
  
  showEntryElement: (entryEl) ->
    $('#showEntry').children().hide()
    @hideEntryField()
    $('#showEntry').show()
    entryEl.show()
    
    bedsheetId = entryEl.data 'imageid'
    @publish 'bedsheet.change', bedsheetId if bedsheetId?
  
  'history.entry.show subscribe': (called, data) ->
    @showEntryById data.id
    
  '.thumb-2d click': (el) ->
    @historyAdd {
      controller: 'entry'
      action: 'show'
      id: @data el
    }
    
}