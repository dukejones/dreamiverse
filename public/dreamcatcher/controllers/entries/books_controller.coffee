$.Controller 'Dreamcatcher.Controllers.Entries.Books', {
  pluginName: 'books'
}, {

  # Don't forget permissions on books

  model: {
    book: Dreamcatcher.Models.Book
    entry: Dreamcatcher.Models.Entry
  }
  
  el: {    
    bookMatrix: $("#entriesIndex .matrix.bookIndex")
    book: (arg) ->
      return $(".book[data-id=#{arg}]", @element) if parseInt(arg) > 0
      return arg.closest '.book' if arg?
      return null
  }
  
  data: (el) ->
    return el.data type if type?
    return el.data 'id' if el?
    return null
    
  resetUrl: -> 
    username = $('#userInfo').data 'username'
    window.history.pushState null, null, "/#{username}"
    
    
  init: (el) ->
    @element = $(el)
    @publish 'book.drop', @element
    @publish 'book.drop', $('#contextPanel')
    
    
  moveEntryToBook: (entryEl, bookEl) ->
    entryId = @data entryEl
    bookId = @data bookEl
    bookId = null if bookEl.parent().attr('id') is 'contextPanel'
    entryMeta = {book_id: bookId}

    @model.entry.update entryId, {entry: entryMeta}
    @publish 'books.close', bookEl
    $('.entryDrop-active', bookEl).hide()

  'book.drop subscribe': (called, parent) ->
    $('.book, .avatar', parent).each (i, el) =>
      @publish 'books.close', $(el)
      $(el).droppable {         
        drop: (ev, ui) =>
          dropEl = $(ev.target)
          @moveEntryToBook ui.draggable, dropEl

        over: (ev, ui) =>
          el = $(ev.target)
          @publish 'books.hover', el if el.hasClass 'book'
          $('.add-active', ui.helper).show()
          $('.entryDrop-active, .entryRemove', el).show()

        out: (ev, ui) =>
          el = $(ev.target)
          @publish 'books.close', el if el.hasClass 'book' 
          $('.add-active', ui.helper).hide()
          $('.entryDrop-active, .entryRemove', el).hide()
      }
  
  #- new book
    
  'books.create subscribe': ->
    newBookEl = $(".book[data-id='new']", @element)
    if newBookEl.exists()
      @editBook newBookEl
      return
      
    @model.book.new {}, (html) =>
      $('#welcomePanel').hide()
      @element.prepend html
      bookEl = $('.book:first', @element)
      @editBook bookEl
      @publish 'dom.added', bookEl
    
  #- show book
  
  showBook: (bookId) ->
    @publish 'context_panel.book', bookId
    @model.book.show bookId, {}, (html) =>
      $('#entryField, #entriesIndex').children().hide()
      bookMatrixEl = @el.bookMatrix
      $('#entriesIndex').append html
      $('#entriesIndex').fadeIn 500
      @publish 'appearance.change'
      #@publish 'entries.drag', @el.bookMatrix

  'books.show subscribe': (called, data) ->
    @showBook data.id

  #- open for edit
  editBook: (el) ->
    @openBook el, true
    
  'books.modify subscribe': (called, el) ->
    @editBook el
  
  #- open 
  openBook: (el, edit) ->
    @closeAllBooks()
    bookEl = @el.book el
    $('.open, .closeClick', bookEl).show()
    $('.control-panel', bookEl).toggle edit
    $('.closed', bookEl).hide()
    
  'books.hover subscribe': (called, el) ->
    @openBook el, false
    
  #- close
  closeBook: (el) ->
    bookEl = @el.book el
    $('.open', bookEl).hide()
    $('.open', bookEl).children().hide()
    $('.closed', bookEl).show()
  
  'books.close subscribe': (called, el) ->
    @closeBook @el.book el
    @resetUrl()

  '.closeClick, .confirm click': (el) ->
    @closeBook @el.book el
    @resetUrl()
  
  #-- all
  
  closeAllBooks: (el) ->
    @closeBook()
  
  'body.clicked subscribe': (called, data) ->
    @closeAllBooks()
      
  #- paging
  
  showPage: (el, page) ->
    bookEl = @el.book el
    $('.open', bookEl).children().hide()
    $('.closeClick', bookEl).show()
    $(".#{page}-panel", bookEl).show() if page?
    
    @createUploader bookEl if page is 'cover'
        
  #-- panels
  
  '.book .control-panel .color click': (el) ->
    @showPage el, 'color'

  '.book .control-panel .coverImage click': (el) ->
    @showPage el, 'cover'

  '.book .control-panel .access click': (el) ->
    @showPage el, 'access'

  '.book .open .back click': (el) ->
    @showPage el, 'control'
    
  #-- more settings

  showMore: (el) ->
    bookEl = @el.book el
    $('.settings-basic', bookEl).toggle()
    $('.more-settings', bookEl).toggle()

  '.book .arrow click': (el) ->
    @showMore el    

  #- save book
  
  saveBook: (el, meta) ->
    bookEl = @el.book el
    bookId = @data bookEl
    params = {book: meta}
    if bookId is 'new'
      @model.book.create params, (data) =>
        bookEl.data 'id', data.book.id if data.book?
    else
      @model.book.update bookId, params
  
  #-- title

  saveTitle: (el) ->
    bookEl = @el.book el
    title = el.val()
    $('.title', bookEl).text title
    @saveBook el, { title: title }

  '.titleInput blur': (el) ->
    @saveTitle el

  '.titleInput keypress': (el, ev) ->
    @saveTitle el if ev.keyCode is 13 # enter key

  
  #-- color
  
  '.color-panel .swatches li click': (el) ->
    color = el.attr 'class'
    bookEl = @el.book(el).attr 'class', "book #{color}"
    @saveBook el, {color: color}
  
  #-- access
  
  '.access-panel .select-menu change': (el) ->
    meta = {}
    meta[el.attr('name')] = el.val()
    @saveBook el, meta
    
  #- disable book
    
  disableBook: (el) ->
    if confirm 'are you sure?'
      bookEl = @el.book el
      @model.book.disable @data bookEl, =>
        bookEl.remove()
        @resetUrl()
  
  '.more-settings .remove click': (el) ->
    @disableBook el
      
  #- uploader
    
  createUploader: (el) ->
    $('.cover-panel', el).uploader {
      singleFile: true
      params: {
        image: {
          section: 'book covers'
          category: 'all'
        }
      }
      classes: {
        button: 'add'
        drop: 'dropbox'
        list: 'dropbox-field-shine'
      }
      onSubmit: @callback('uploadSubmit', el)
      onComplete: @callback('uploadComplete', el)
    }
  
  uploadSubmit: (el, id, fileName) ->
    $('.dropbox-field-shine .add', el).hide()
  
  uploadComplete: (el, id, fileName, result) ->
    image = result.image
    if image?
      $('.uploading', el).remove()
      el.data 'image', image.id
      background = "url(/images/uploads/#{image.id}-252x252.#{image.format})"
      $('.cover, .dropbox-field-shine', el).css 'background-image', background
      $('.dropbox-field-shine li', el).remove() #todo: remove upload progress
      @saveBook el, { cover_image_id: image.id }
      
    $('.dropbox-field-shine .add', el).show()
    
}