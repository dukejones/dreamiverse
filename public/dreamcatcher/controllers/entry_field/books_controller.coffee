$.Controller 'Dreamcatcher.Controllers.EntryField.Books',

  model: {
    entry : Dreamcatcher.Models.Entry
    book : Dreamcatcher.Models.Book
  }
  
  el: {    
    bookMatrix: (el) ->
      return $('#entryField .matrix.books[id=#{bookId}]') if el?
      return $('#entryField .matrix.dreamfield') 
    book: (el) ->
      return el.closest '.book' if el?
      return null
  }
  
  helper: {
    upload: Dreamcatcher.Classes.UploadHelper
  }
  
  data: (el) ->
    return el.data type if type?
    return el.data 'id' if el?
    return null
  
  #- move
  
  addEntryToBook: (entryEl, bookEl) ->
    entryId = @data entryEl
    bookId = @data bookEl
    entryMeta = {book_id: bookId}

    @model.entry.update entryId, {entry: entryMeta}, =>
      @closeBook bookEl
      entryEl.appendTo @el.bookMatrix bookEl

    $('.entryDrop-active', bookEl).hide()
      
  #- open/close
  
  openBook: (el) ->
    @closeAllBooks()
    log el
    bookEl = @el.book el
    log bookEl
    $('.open, .closeClick', bookEl).show()
    $('.closed', bookEl).hide()
    
    
  '.closed .edit click': (el) ->
    @openBook el
      
  closeBook: (el) ->
    bookEl = @el.book el
    $('.open', bookEl).hide()
    $('.closed', bookEl).show()

  closeAllBooks: (el) ->
    @closeBook()
  
  '.closeClick, .confirm click': (el) ->
    @closeBook @el.book el
        
  #- pages
  
  showPage: (el, page) ->
    bookEl = @el.book el
    $('.open', bookEl).children().hide()
    $('.closeClick', bookEl).show()
    $(".#{page}-panel", bookEl).show() if page?
        
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

  #- book saving
  
  saveBook: (el, meta) ->
    bookEl = @el.book el
    bookId = @data el
    params = {book: meta}
    if bookId is 'new'
      @model.book.create params, (data) =>
        bookEl.data 'id', data.book.id if data.book?
    else
      @model.book.update bookId, params
  
  '.color-panel .swatches li click': (el) ->
    color = el.attr 'class'
    bookEl = @el.book(el).attr 'class', "book #{color}"
    @saveBook el, {color: color}
  
  '.access-panel .select-menu change': (el) ->
    meta = {}
    meta[el.attr('name')] = el.val()
    @saveBook el, meta
    
  saveTitle: (el) ->
    bookEl = @getBookElement el
    title = el.val()
    $('.title', bookEl).text title
    @saveBook el, { title: title }
    
  '.titleInput blur': (el) ->
    @saveTitle el
    
  '.titleInput keypress': (el, ev) ->
    @saveTitle el if ev.keyCode is 13 # enter key
    
  disableBook: (el) ->
    if confirm 'are you sure?'
      bookEl = @el.book el
      @model.book.disable @data bookEl
      bookEl.remove()
  
  '.more-settings .remove click': (el) ->
    @disableBook el
      
  #- uploader
    
  createUploader: (el) ->
    @uploader = @helper.upload.create {
      element: $('.cover-panel', el)
      params: {
        image: {
          section: 'book covers'
          category: 'all'
          genre: ''
        }
      }
      url: '/images'#.json
      button: 'add'
      drop: 'dropbox'
      list: 'dropbox-field-shine'
    }, @callback('uploadSubmit', el), @callback('uploadComplete', el)
    
  uploadSubmit: (el, id, fileName) ->
    $('.dropbox-field-shine .add', el).hide()

  uploadComplete: (el, id, fileName, result) ->
    image = result.image
    if image?
      el.data 'image', image.id
      background = "url(/images/uploads/#{image.id}-252x252.#{image.format})"
      $('.cover, .dropbox-field-shine', el).css 'background-image', background
      $('.dropbox-field-shine li', el).remove() #todo: remove upload progress
      @saveBook el, {cover_image_id: image.id}
      
    $('.dropbox-field-shine .add', el).show()