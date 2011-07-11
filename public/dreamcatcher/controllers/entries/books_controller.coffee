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
    @setupDroppable()
    if creating
      @edit()
      @publish 'app.initUi', @element
  
  show: ->
    bookId = @bookId()
    @publish 'context_panel.book', bookId
    Book.show bookId, {}, (html) =>
      $('#entryField, #entriesIndex').children().hide()
      $('#entriesIndex').append html
      $('#entriesIndex').fadeIn 500
      @publish 'appearance.change'
      #@setupEntryDragging()
      #@publish 'book.drop', $('#contextPanel')

  ###
  setupEntryDragging: ->
    $('#entriesIndex .bookIndex .thumb-2d').draggable {
      containment: 'document'
      zIndex: 100
      revert: 'invalid'
      # helper: 'clone'
      distance: 15
      start: (ev, ui) =>
        $('#contextPanel .book').hide()
        $('.avatar, .avatar .entryRemove', '#contextPanel').show()
      stop: (ev, ui) =>
        $('#contextPanel .book').show()
        $('.avatar, .avatar .entryRemove', '#contextPanel').hide()
    }
  ###
    
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
  
  showPage: (page) ->
    if page is 'more'
      $('.settings-basic', @element).toggle()
      $('.more-settings', @element).toggle()
    else
      $('.open', @element).children().hide()
      $('.closeClick', @element).show()
      $(".#{page}-panel", @element).show() if page?
      @initUploader() if page is 'cover'

  saveMeta: (name, value) ->
    meta = {}
    meta[name] = value
    @save meta
    @element.attr 'class', "book #{value}" if name is 'color'
    $('.title', @element).text value if name is 'title'
    
  save: (meta) ->
    params = {book: meta}
    if @bookId() is 'new'
      Book.create params, (data) =>
        @element.data 'id', data.book.id if data.book?
    else
      Book.update @bookId(), params
    
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
  '.more-settings .remove click': (el) -> @delete()
  
  #- saveMeta
  '.titleInput blur': -> @saveMeta 'title', el.val()
  '.titleInput keypress': (el, ev) -> @saveMeta('title', el.val()) if ev.keyCode is 13 # enter key
  '.color-panel .swatches li click': (el) -> @saveMeta 'color', el.attr 'class'
  '.access-panel .select-menu change': (el) -> @saveMeta el.attr('name'), el.val()
  
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

  setupDroppable: ->
    @element.droppable {         
      drop: (ev, ui) =>
        @moveEntryToBook ui.draggable
      over: (ev, ui) =>
        $('.add-active', ui.helper).show()
        @open false
        $('.entryDrop-active, .entryRemove', @element).show()
      out: (ev, ui) =>
        @close()
        $('.add-active', ui.helper).hide()
        $('.entryDrop-active, .entryRemove', @element).hide()
    }

  moveEntryToBook: (entryEl) ->
    entryId = entryEl.data 'id'
    entryMeta = {book_id: @bookId()}
    Entry.update entryId, {entry: entryMeta}, => entryEl.remove()
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
      @saveBook el, { image_id: image.id }

    $('.dropbox-field-shine .add', el).show()

}