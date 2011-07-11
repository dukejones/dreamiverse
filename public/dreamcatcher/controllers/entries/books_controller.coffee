$.Controller 'Dreamcatcher.Controllers.Entries.Books', {
  pluginName: 'books'
}, {
  ###
  el: {    
    bookMatrix: -> return $("#entriesIndex .bookIndex")
    book: (arg) ->
      return $(".book[data-id=#{arg}]", @element) if parseInt(arg) > 0
      return arg.closest '.book' if arg?
      return null
  }
  
  data: (el) ->
    return el.data type if type?
    return el.data 'id' if el?
    return null
  ###
  
  bookId: -> @element.data 'id'
    
  resetUrl: -> 
    username = $('#currentUserInfo').data 'username'
    window.history.pushState null, null, "/#{username}"
    
  init: (el, field, creating) ->
    @element = $(el)
    @field = field
    if creating
      @edit()
      @publish 'app.initUi', @element
    #@publish 'book.drop', @element
  
  ###
  moveEntryToBook: (entryEl, bookEl) ->
    entryId = @data entryEl
    bookId = @data bookEl
    bookId = '' if bookEl.parent().attr('id') is 'contextPanel'
    entryMeta = {book_id: bookId}

    Entry.update entryId, {entry: entryMeta}, =>
      if bookId is ''
        entryEl.appendTo('#entriesIndex .matrix.index') 
      else
        entryEl.remove()
        
    @publish 'books.close', bookEl
    $('.entryDrop-active', bookEl).hide()
  
  makeDroppable: (el) ->
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
  ###
  
  #- new book
  
  #- show book
  
  show: ->
    bookId = @bookId()
    log bookId
    @publish 'context_panel.book', bookId
    Book.show bookId, {}, (html) =>
      $('#entryField, #entriesIndex').children().hide()
      #bookMatrixEl = @el.bookMatrix
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
    
  #- open for edit
  edit: -> @open true
    
  #- open 
  open: (edit) ->
    @publish 'books.close' #closes all books
    $('.open, .closeClick', @element).show()
    $('.control-panel', @element).toggle edit
    $('.closed', @element).hide()
    
  #- close
  close: ->
    $('.open', @element).hide()
    $('.open', @element).children().hide()
    $('.closed', @element).show()
      
  #- paging
  
  showPage: (page) ->
    if page is 'more'
      $('.settings-basic', @element).toggle()
      $('.more-settings', @element).toggle()
    else
      $('.open', @element).children().hide()
      $('.closeClick', @element).show()
      $(".#{page}-panel", @element).show() if page?
      @initUploader() if page is 'cover'

  #- save book
  
  save: (meta) ->
    params = {book: meta}
    if @bookId() is 'new'
      Book.create params, (data) =>
        @element.data 'id', data.book.id if data.book?
    else
      Book.update @bookId(), params
  
  #-- title

  saveTitle: (el) ->
    title = el.val()
    $('.title', @element).text title
    @save @element, { title: title }

  #- disable book
    
  delete: ->
    if confirm 'are you sure?'
      Book.destroy @bookId(), =>
        @element.remove()
        @resetUrl()
        @publish 'entries.index', {reload: true}
      
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
  
  ## Event Binding ##
  #-- panels
  '.control-panel .color click': -> @showPage 'color'
  '.control-panel .coverImage click': -> @showPage 'cover'
  '.control-panel .access click': -> @showPage 'access'
  '.open .back click': -> @showPage 'control'
  '.arrow click': -> @showPage 'more'    
  '.titleInput blur': -> @saveTitle()
  '.titleInput keypress': (el, ev) -> @saveTitle() if ev.keyCode is 13 # enter key

  #-- color

  '.color-panel .swatches li click': (el) ->
    color = el.attr 'class'
    bookEl = @element.attr 'class', "book #{color}"
    @save {color: color}

  #-- access

  '.access-panel .select-menu change': (el) ->
    meta = {}
    meta[el.attr('name')] = el.val()
    @save meta

  '.more-settings .remove click': (el) ->
    @delete()
  
  ## Subscriptions ##
  ###
  'book.drop subscribe': (called, parent) ->
    $('.book, .avatar', parent).each (i, el) =>
      @publish 'books.close', $(el)
      @makeDroppable $(el)


  ###

  
  'books.close subscribe': -> @close()
  'body.clicked subscribe': -> @close()
  'books.show subscribe': (called, data) ->
    return unless data.id.toString() is @bookId().toString()
    @show()
  
  'books.hover subscribe': -> @open false  
  
  #@publish 'entries.index', { newBook: true }
  'books.edit subscribe': (called, data) ->
    return unless data.id.toString() is @bookId().toString()
    @field.show()
    @edit()
  ###
  'books.modify subscribe': (called, data) ->
    @edit() if data.id is @bookId()
    #@publish 'entries.index', { editBook: data.id }
  ###

}