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
  
  #- new book
  
  newBook: ->
    @model.book.new {}, (html) =>
      $('#welcomePanel').hide()
      $('#entryField .matrix.books').prepend html
      bookEl = $('#entryField .matrix.books .book:first')
      @books.openBook bookEl
      @publish 'dom', {el: bookEl}
    
  'history.book.new subscribe': (called, data) ->
    @newBook()
    
  #- show book
  
  showBook: (bookId) ->
    bookEl = @el.book bookId
    html = bookEl.clone().css 'z-index', 2000
    if $('#contextPanel .book').exists()
      $('#contextPanel .book').replaceWith html
    else
      $('#contextPanel').prepend html
    @publish 'drop', { el: $('#contextPanel') }

    @model.book.show bookId, {}, (html) =>
      $('#entryField').children().hide()
      bookFieldEl = @el.bookField bookId
      if bookFieldEl.exists()
        bookFieldEl.replaceWith html
      else
        $('#entryField').append html
      @publish 'drag', { el: @el.bookField }
    
  'history.book.show subscribe': (called, data) ->
    @showBook data.id
    
  '.book .mask, .spine click': (el) ->
    @historyAdd {
      controller: 'book'
      action: 'show'
      id: @data el.closest '.book, .spine'
    }
      
  #- open book
  
  openBook: (el) ->
    @closeAllBooks()
    bookEl = @el.book el
    $('.open, .closeClick', bookEl).show()
    $('.closed', bookEl).hide()
    
    
  '.closed .edit click': (el) ->
    @openBook el
    
  #- close book
      
  closeBook: (el) ->
    bookEl = @el.book el
    $('.open', bookEl).hide()
    $('.closed', bookEl).show()

  '.closeClick, .confirm click': (el) ->
    @closeBook @el.book el
  
  #-- all
  
  closeAllBooks: (el) ->
    @closeBook()
  
  'bodyClick subscribe': (called, data) ->
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
    bookEl = el.book el
    $('.settings-basic', bookEl).toggle()
    $('.more-settings', bookEl).toggle()

  '.book .arrow click': (el) ->
    @showMore el    

  #- save book
  
  saveBook: (el, meta) ->
    bookEl = @el.book el
    bookId = @data el
    params = {book: meta}
    if bookId is 'new'
      @model.book.create params, (data) =>
        bookEl.data 'id', data.book.id if data.book?
    else
      @model.book.update bookId, params
  
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
    
  #-- title
    
  saveTitle: (el) ->
    bookEl = @getBookElement el
    title = el.val()
    $('.title', bookEl).text title
    @saveBook el, { title: title }
    
  '.titleInput blur': (el) ->
    @saveTitle el
    
  '.titleInput keypress': (el, ev) ->
    @saveTitle el if ev.keyCode is 13 # enter key
    
  #- disable book
    
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