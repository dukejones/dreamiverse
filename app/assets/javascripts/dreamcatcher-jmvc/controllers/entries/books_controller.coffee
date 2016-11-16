$.Controller 'Dreamcatcher.Controllers.Entries.Books', {
  pluginName: 'books'
}, {
  
  bookId: -> @element.data 'id'
    
  resetUrl: -> 
    username = $('#currentUserInfo').data 'username'
    window.history.pushState null, null, "/#{username}"
    
  init: (el, field, creating) ->
    @element = $(el)
    @field = field
    @setupDroppable() unless @bookId() is 'new'
    if creating
      @edit()
      @publish 'app.initUi', @element
  
  show: ->
    bookId = @bookId()
    @publish 'context_panel.book', bookId
    @publish 'app.loading'
    Book.show bookId, {}, (html) =>
      @publish 'app.loading', false
      $('#entryField, #entriesIndex').children().hide()
      $('#entriesIndex').append html
      $('#entriesIndex').fadeIn 500
      @publish 'appearance.change'
      @setupEntryDragging()
    
  edit: -> @open true
     
  open: (edit) ->
    @publish 'books.close' #closes all books
    $('.open, .closeClick', @element).show()
    $('.control-panel', @element).toggle edit
    $('.closed', @element).hide()
    
  close: ->
    $('.open', @element).hide()
    $('.open', @element).children().hide()
    $('.closed', @element).show()
    @saveMeta('title', 'Untitled') if @bookId() is 'new'
  
  showPage: (page) ->
    if page is 'more'
      $('.settings-basic', @element).toggle()
      $('.more-settings', @element).toggle()
    else
      $('.open', @element).children().hide()
      $('.closeClick', @element).show()
      $(".#{page}-panel", @element).show() if page?
      @initUploader() if page is 'cover'

  saveMeta: (name, value, format) ->
    meta = {}
    meta[name] = value
    promise = @save meta
    switch name
      when 'color'
        promise.done => @element.attr 'class', "book #{value}"
      when 'title'
        promise.done => $('.title', @element).text value
      when 'image_id'
        bg = if format? then "url(/assets/uploads/#{value}-bookcover.#{format})" else ''
        promise.done => $('.cover, .dropbox-field-shine', @element).css {
          'background-image': bg
        }
    
  save: (meta) ->
    params = {book: meta}
    if @bookId() is 'new'
      return Book.create params, (data) =>
        bookId = data.book.id
        @element.attr 'data-id', bookId
        $('.mask', @element).attr 'href', "/books/#{bookId}"
        $('.edit', @element).attr 'href', "/books/#{bookId}/edit"
    else
      return Book.update @bookId(), params
    
  delete: ->
    return unless confirm 'are you sure?'
    Book.destroy @bookId(), =>
      @element.remove()
      @resetUrl()
        
  #- showPage
  '.control-panel .color click': -> @showPage 'color'
  '.control-panel .coverImage click': -> @showPage 'cover'
  '.control-panel .access click': -> @showPage 'access'
  '.open .back click': -> @showPage 'control'
  '.arrow click': -> @showPage 'more'    

  #- delete
  '.more-settings .remove click': -> @delete()
  
  #- saveMeta
  '.titleInput blur': -> @saveMeta 'title', el.val()
  '.titleInput focus': (el) -> el.select()
  '.titleInput keypress': (el, ev) -> @saveMeta('title', el.val()) if ev.keyCode is 13 # enter key
  '.color-panel .swatches li click': (el) -> @saveMeta 'color', el.attr 'class'
  '.access-panel .select-menu change': (el) -> @saveMeta el.attr('name'), el.val()
  '.cover-panel .close click': ->
    @saveMeta 'image_id',''
    $('.cover, .dropbox-field-shine', @element).css 'background-image', ''
  
  #- close, show, edit
  'books.close subscribe': -> @close()
  'body.clicked subscribe': -> @close()
  
  'books.show subscribe': (called, data) ->
    return unless data.id.toString() is @bookId().toString()
    @show()
    
  'books.edit subscribe': (called, data) ->
    return unless data.id.toString() is @bookId().toString()
    @field.show()
    @edit()
    
  setupEntryDragging: ->
    $('#entriesIndex .bookIndex .thumb-2d').draggable {
      containment: 'document'
      zIndex: 100
      revert: 'invalid'
      distance: 15
      start: (ev, ui) =>
        $('#contextPanel .book').hide()
        $('.avatar, .avatar .entryRemove', '#contextPanel').show()
      stop: (ev, ui) =>
        $('#contextPanel .book').show()
        $('.avatar, .avatar .entryRemove', '#contextPanel').hide()
    }

  setupDroppable: ->
    @element.droppable {         
      drop: (ev, ui) =>
        @moveEntryToBook ui.draggable, false
      over: (ev, ui) =>
        $('.add-active', ui.helper).show()
        @open false
        $('.entryDrop-active, .entryRemove', @element).show()
      out: (ev, ui) =>
        @close()
        $('.add-active', ui.helper).hide()
        $('.entryDrop-active, .entryRemove', @element).hide()
    }

  moveEntryToBook: (entryEl, remove) ->
    entryId = entryEl.data 'id'
    bookId = if remove then '' else @bookId()
    entryMeta = {book_id: bookId}
    Entry.update entryId, {entry: entryMeta}, => entryEl.remove()
    unless remove
      @close()
      $('.entryDrop-active', bookEl).hide()

  #- uploader

  initUploader: ->
    $('.cover-panel', @element).uploader {
      singleFile: true
      params: {
        image: {
          section: 'book covers'
          category: 'all'
        }
      }
      classes: { #TODO: remove
        button: 'add'
        drop: 'dropbox'
        list: 'dropbox-field-shine'
      }
      onSubmit: => $('.add', @element).hide()
      onComplete: @callback('uploadComplete')
    }

  uploadComplete: (id, fileName, result) ->
    image = result.image
    if image?
      $('.add', @element).show()
      $('.uploading').remove()
      @saveMeta 'image_id', image.id, image.format

}