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
    @showEntry = new Dreamcatcher.Controllers.Entries.Show $('#showEntry')
    @books = new Dreamcatcher.Controllers.Entries.Books $('#entryField .matrix.books')
    @comments = new Dreamcatcher.Controllers.Entries.Comments $('#entryField')
    @contextPanel = new Dreamcatcher.Controllers.Users.ContextPanel $('#contextPanel')
    
    if $('#entryField .matrix').exists()
      @showEntryField()
    @publish 'book.drop', $('#entryField .matrix.books')
    @publish 'entry.drag', $('#entryField .matrix.field')
          
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


  'book.drop subscribe': (called, data) ->
    parentEl = data
    $('.book, .avatar', parentEl).each (i, el) =>
      @books.closeBook $(el)
      $(el).droppable {         
        drop: (ev, ui) =>
          dropEl = $(ev.target)
          @moveEntryToBook ui.draggable, dropEl

        over: (ev, ui) =>
          el = $(ev.target)
          @books.openBook el, true if el.hasClass 'book'
          $('.add-active', ui.helper).show()
          $('.entryDrop-active, .entryRemove', el).show()

        out: (ev, ui) =>
          el = $(ev.target)
          @books.closeBook el if el.hasClass 'book' 
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
        #$(ui.helper).css 'opacity', 0.5
        @toggleBookContext true
        
      stop: (ev, ui) =>
        #$(ui.helper).css 'opacity', 1
        @toggleBookContext false
        
    }
  
  #- hides the book if it sits in the context menu
  toggleBookContext: (start) ->
    if not $('#entryField .matrix.field').is ':visible'
      $('#contextPanel .book').toggle not start
      $('#contextPanel .avatar').toggle start

  #- context panels
  
  showEntryContext: (userId) ->    
    #todo: should only get context panel if for the user it doesn't exist in the dom.
    params = { type: 'entry' }
    if not userId?
      $.extend params, { user_id: userId }
    @model.entry.showContext params, (html) =>
      $('#streamContextPanel').hide()
      $('#totem').replaceWith html
      @contextPanel = new Dreamcatcher.Controllers.Users.ContextPanel $('#contextPanel')
      $('#totem').show()

  showStreamContext: ->
    if $('#streamContextPanel').exists()
      $('#contextPanel').hide()
      $('#streamContextPanel').show()
    else    
      @model.entry.showContext {type:'stream'}, (html) =>
        $('#contextPanel').hide()
        $('#totem').after html
        @publish 'dom.added', $('#streamContextPanel')
        @stream = new Dreamcatcher.Controllers.Stream $("#streamContextPanel")
  
  #- entry field
  
  hideEntryField: ->
    $('#entryField').children().hide()#fadeOut 'fast'
  
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
  
  'history.entry.field subscribe': (called, data) ->
    @showEntryContext()
    @showEntryField()
    
  #- stream
        
  showEntryStream: ->
    if $('#entryField .matrix.stream').exists()
      @hideEntryField()
      $('#entryField .matrix.stream').show()
    else
      @model.entry.showStream {}, (html) =>
        @hideEntryField()
        $('#entryField').append html
        $('#entryField .matrix.stream a.left').removeAttr 'href'
        $('#entryField .matrix.stream a.tagCloud').removeAttr 'href'
        @comments.load $('entryField .matrix.stream')
    @publish 'appearance.change'
  
  'history.entry.stream subscribe': (called, data) ->
    @showStreamContext()
    @showEntryStream()
    
  #- new entry
    
  newEntry: ->
    $('#showEntry').hide() #todo ?
    # TODO: if new already showing, just bring up
    @model.entry.new {}, (html) =>
      $('#entryField').children().hide()
      if $('#new_entry').exists()
        $('#new_entry').replaceWith html
      else
        $('#entryField').prepend html
      $('#new_entry').show()
      
      @new = new Dreamcatcher.Controllers.Entries.New $('#new_entry')
      @publish 'dom.added', $('#new_entry')
  
  'history.entry.new subscribe': (called, data) ->
    @showEntryContext()
    @newEntry()
  
  #- new book
    
  'history.book.new subscribe': (called, data) ->
    @showEntryContext()
    @showEntryField()
    @books.newBook()
    
  #- edit entry
  
  editEntry: (id) ->
    $('#entryField').children().hide()
    @model.entry.edit {id: id}, (html) =>
      $('#entryField').prepend html
      entryEl = $('#entryField .edit_entry:first')
      entryEl.show()
      # TODO: fitToContent()
      @publish 'dom.added', entryEl

  'history.entry.edit subscribe': (called, data) ->
    @showEntryContext data.user_id if data.user_id?
    @editEntry data.id
    
  #- show entry
  
  showEntryById: (id) ->
    entryEl = @el.entry id
    if entryEl.exists()
      @showEntryElement entryEl
    else
      @model.entry.show {id: id}, (html) =>
        $('#showEntry').append html
        @showEntryElement @el.entry id
        showEntryEl = $('#showEntry .entry:last')
        @comments.load showEntryEl
        showEntryEl.linkify().videolink()
  
  showEntryElement: (entryEl) ->
    $('#showEntry').children().hide()
    @hideEntryField()
    $('#showEntry').show()
    entryEl.show()
    @publish 'appearance.change', entryEl.data 'viewpreference'
    
  'history.entry.show subscribe': (called, data) ->
    @showEntryContext data.user_id if data.user_id?
    @showEntryById data.id
    
  '.thumb-2d click': (el) ->
    @historyAdd {
      controller: 'entry'
      action: 'show'
      id: @data el
    }
    
  '.thumb-1d a.left, .thumb-1a a.tagCloud click': (el) ->
    thumbEl = el.closest('.thumb-1d')
    @historyAdd {
      controller: 'entry'
      action: 'show'
      id: thumbEl.data 'id'
      user_id: thumbEl.data 'userid'
    }
    
}