$.Controller 'Dreamcatcher.Controllers.Entries.Books',

  model: Dreamcatcher.Models.Book
  entryModel: Dreamcatcher.Models.Entry
  
  init: ->
    @model.get {}, @callback('populate')
    
    
  populate: (html) ->
    $('#entryField .matrix').prepend html
    
    $('#entryField .book').each (i, el) =>
      @closeBook $(el)
      $(el).droppable {         
        drop: (ev, ui) =>
          entryMeta = {
            entry: {
              book_id: $(ev.target).data 'id'
            }
          }
          entryId = ui.draggable.data 'id'
          @entryModel.update entryId, entryMeta, =>
            notice 'successful moved'
            ui.draggable.remove()

        over: (ev, ui) =>
          bookEl = $(ev.target)
          @openBook bookEl
          $('.entryDrop-active', bookEl).show()
      }
      
    $('#entryField .thumb-2d').each (i, el) =>
      $('a.link',el).remove()

    $('#entryField .thumb-2d').draggable {
      containment: 'document'
      zIndex: 100
      revert: true
    }
    

  getBookElement: (el) ->
    return el.closest '.book'

          
  newBook: ->
    @model.new {}, (html) =>
      $('#entryField .matrix').prepend html
      @openBook $('#entryField .matrix .book:first')
      
  #book close book
          
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
            
        
  # go into book
  
  showBookById: (bookId) ->
    @model.show bookId, {}, (html) =>
      $('#entryField').children().hide()
      $('#entryField').append html
      $('#contextPanel').prepend $("#entryField .book[data-id=#{bookId}]").clone()
    
  '.book .flat click': (el) ->
    bookEl = el.closest '.book'
    bookId = bookEl.data 'id'
    $.history.load "b=#{bookId}"
        
        
  # book control-panel

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
  
  changeBookColor: (el, color) ->
    bookEl = @getBookElement el
    bookEl.attr 'class', 'book'
    bookEl.addClass color
    bookEl.data 'color', color

  '.book .color-panel .swatches li click': (el) ->
    color = el.attr 'class'
    @changeBookColor el, color
    @saveBook el, { color: color }
  
  '.select-menu change': (el) ->
    book = {}
    book[el.attr('name')] = el.val()
    @saveBook el, book
    
  '.titleInput blur': (el) ->
    @saveBook el, { title: el.val() }
    
  '.titleInput keypress': (el, ev) ->
    if ev.keyCode is 13 #enter
      @saveBook el, { title: el.val() }
      

  saveBook: (el, bookMeta) ->
    bookEl = @getBookElement el
    bookId = bookEl.data 'id'
    if bookId is 'new'
      @model.create { book: bookMeta }, (data) =>
        if data.book?
          bookEl.data 'id', data.book.id
    else
      bookId = parseInt bookId
      @model.update bookId, { book: bookMeta }
      
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