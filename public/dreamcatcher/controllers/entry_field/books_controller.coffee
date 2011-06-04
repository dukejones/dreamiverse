$.Controller 'Dreamcatcher.Controllers.EntryField.Books',

  entryModel: Dreamcatcher.Models.Entry
  bookModel: Dreamcatcher.Models.Book
      
  addEntryToBook: (entryEl, bookEl) ->
    entryId = entryEl.data 'id'
    bookId = if bookEl? then bookEl.data 'id' else null
    
    entryMeta = { book_id: bookId }
    entryEl.hide()
    @entryModel.update entryId, { entry: entryMeta }
    
    @closeBook bookEl
    $('.entryDrop-active', bookEl).hide()
    
  getBookElement: (el) ->
    return el.closest '.book'
      
  #- open/close
  
  closeBook: (el) ->
    bookEl = el.closest '.book'
    $('.open', bookEl).hide()
    $('.closed', bookEl).show()
    
  closeAllBooks: ->
    $('.book .open').hide()
    $('.book .closed').show()
    
  openBook: (el) ->
    @closeAllBooks()
    
    bookEl = el.closest '.book'
    $('.open', bookEl).show()
    $('.closed', bookEl).hide()
    
    $('.closeClick', bookEl).show()
    
    
  '.book .closed .edit click': (el) ->
    @openBook el
    
  '.closeClick, .confirm click': (el) ->
    @closeBook @getBookElement el
        
        
  #- control-panel
  
  showPage: (el, page) ->
    bookEl = el.closest '.book'
    $('.open', bookEl).children().hide()
    $('.closeClick', bookEl).show()
    $(".#{page}-panel", bookEl).show()
    @createUploader bookEl if page is 'cover'

  '.book .control-panel .color click': (el) ->
    @showPage el, 'color'
    
  '.book .control-panel .coverImage click': (el) ->
    @showPage el, 'cover'
    
  '.book .control-panel .access click': (el) ->
    @showPage el, 'access'
    
  '.book .open .back click': (el) ->
    @showPage el, 'control'

    
  showMore: (el) ->
    bookEl = el.closest '.book'
    $('.settings-basic', bookEl).toggle()
    $('.more-settings', bookEl).toggle()
    
  '.book .arrow click': (el) ->
    @showMore el

  #book saving
  '.book .color-panel .swatches li click': (el) ->
    color = el.attr 'class'
    bookEl = @getBookElement el
    bookEl.attr 'class', "book #{color}"
    @saveBook el, { color: color }
  
  '.select-menu change': (el) ->
    book = {}
    book[el.attr('name')] = el.val()
    @saveBook el, book
    
  saveTitle: (el) ->
    bookEl = @getBookElement el
    title = el.val()
    $('.title', bookEl).text title
    @saveBook el, { title: title }
    
  '.titleInput blur': (el) ->
    @saveTitle el
    
  '.titleInput keypress': (el, ev) ->
    @saveTitle el if ev.keyCode is 13 # enter key
    
  '.more-settings .remove click': (el) ->
    @disableBook el
      
  saveBook: (el, bookMeta) ->
    bookEl = @getBookElement el
    bookId = bookEl.data 'id'
    if bookId is 'new'
      @bookModel.create { book: bookMeta }, (data) =>
        if data.book?
          bookEl.data 'id', data.book.id
    else
      bookId = parseInt bookId
      @bookModel.update bookId, { book: bookMeta }
      
  disableBook: (el) ->
    if confirm 'are you sure?'
      bookEl = @getBookElement el
      bookId = bookEl.data 'id'
      @bookModel.disable bookId
      bookEl.remove()
      
  # uploader
    
  createUploader: (el) ->
    @uploader = Dreamcatcher.Classes.UploadHelper.createUploader {
      element: $('.cover-panel', el)
      params: {
        image: {
          section: 'book covers'
          category: 'all'
          genre: ''
        }
      }
      url: '/images.json'
      button: 'add'
      drop: 'dropbox'
      list: 'dropbox-field-shine'
    }, @callback('uploadSubmit', el), @callback('uploadComplete', el)
    
  uploadSubmit: (el, id, fileName) ->
    $('.dropbox-field-shine .add', el).hide()

  uploadComplete: (el, id, fileName, result) ->
    if result.image?
      image = result.image
      el.data 'image', image.id
      $('.cover', el).css 'background-image', "url(/images/uploads/#{image.id}-252x252.#{image.format})"
      $('.dropbox-field-shine', el).css 'background', "transparent url(/images/uploads/#{image.id}-252x252.#{image.format}) no-repeat center center"
      $('.dropbox-field-shine li', el).remove()
      @saveBook el, { cover_image_id: image.id }
      
    $('.dropbox-field-shine .add', el).show()