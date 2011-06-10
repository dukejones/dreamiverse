$.Controller 'Dreamcatcher.Controllers.Entries.Books',

  model: {
    entry : Dreamcatcher.Models.Entry
    book : Dreamcatcher.Models.Book
  }
  
  el: {    
    bookMatrix: (id) ->
      return $("#entryField .matrix.book[data-id=#{id}]") if id?
      return $('#entryField .matrix.field') 
    book: (arg) ->
      return $("#entryField .matrix.books .book[data-id=#{arg}]") if parseInt(arg) > 0
      return arg.closest '.book' if arg?
      return null
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
      @openBook bookEl
      @publish 'dom.added', bookEl
    
  #- show book
  
  showBook: (bookId) ->
    bookEl = @el.book bookId
    html = bookEl.clone().css 'z-index', 2000
    if $('#contextPanel .book').exists()
      $('#contextPanel .book').replaceWith html
    else
      $('#contextPanel').prepend html
    $('#contextPanel .avatar').hide()
    
    @publish 'book.drop', $('#contextPanel')
    
    bookMatrixEl = @el.bookMatrix bookId

    if bookMatrixEl.exists()
      $('#entryField').children().hide()
      bookMatrixEl.show()      
    else
      @model.book.show bookId, {}, (html) =>
        $('#entryField').children().hide()
        bookMatrixEl = @el.bookMatrix bookId
        if bookMatrixEl.exists()
          bookMatrixEl.replaceWith html
        else
          $('#entryField').append html
        @publish 'entry.drag', @el.bookMatrix()
    
  'history.book.show subscribe': (called, data) ->
    @showBook data.id
    #todo: reused from entries (refactor)
    bedsheetId = $('#entryField').data 'imageid'
    @publish 'bedsheet.change', bedsheetId if bedsheetId?
    
  '.book .mask click': (el) ->
    bookEl = el.closest '.book'
    @historyAdd {
      controller: 'book'
      action: 'show'
      id: @data bookEl
    }
      
  #- open book
  
  openBook: (el, empty) ->
    @closeAllBooks()
    bookEl = @el.book el
    $('.open, .closeClick', bookEl).show()
    $('.control-panel', bookEl).toggle(not empty)
    $('.closed', bookEl).hide()
    
    
  '.closed .edit click': (el) ->
    @openBook el
    
  #- close book
      
  closeBook: (el) ->
    bookEl = @el.book el
    $('.open', bookEl).hide()
    $('.open', bookEl).children().hide()
    $('.closed', bookEl).show()

  '.closeClick, .confirm click': (el) ->
    @closeBook @el.book el
  
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
      @model.book.disable @data bookEl
      bookEl.remove()
  
  '.more-settings .remove click': (el) ->
    @disableBook el
      
  #- uploader
    
  createUploader: (el) ->
    log el
    upload = new Dreamcatcher.Controllers.Common.Upload $('.cover-panel', el)
    upload.load {
      params: {
        image: {
          section: 'book covers'
          category: 'all'
          genre: 'all'
        }
      }
      classes: {
        button: 'add'
        drop: 'dropbox'
        list: 'dropbox-field-shine'
      }
      onSubmit: @callback('uploadSubmit', el)
      onComplete: @callback('uploadComplete', el)
    }, true
  
  uploadSubmit: (el, id, fileName) ->
    $('.dropbox-field-shine .add', el).hide()
  
  uploadComplete: (el, id, fileName, result) ->
    image = result.image
    if image?
      el.data 'image', image.id
      background = "url(/images/uploads/#{image.id}-252x252.#{image.format})"
      $('.cover, .dropbox-field-shine', el).css 'background-image', background
      $('.dropbox-field-shine li', el).remove() #todo: remove upload progress
      @saveBook el, { cover_image_id: image.id }
      
    $('.dropbox-field-shine .add', el).show()