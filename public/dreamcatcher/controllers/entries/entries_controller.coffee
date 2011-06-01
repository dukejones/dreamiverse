$.Controller 'Dreamcatcher.Controllers.Entries',
  
  model: Dreamcatcher.Models.Entry

  init: ->
    @books = new Dreamcatcher.Controllers.Entries.Books $('#entryField .matrix') if $("#entryField .matrix").exists()
    $.history.init @callback('hash')
    
  hash: (keyValue) ->
    split = keyValue.split('=')
    key = split[0]
    value = split[1]

    if key is 'e'
      @showEntryById value
    else if key is 'b'
      @books.showBookById value
    else
      @showMatrix()

  newBook: ->
    @books.newBook()
      
  '.thumb-2d click': (el) ->
    entryId = el.data 'id'
    $.history.load "e=#{entryId}"

  hideAllEntries: ->
    $('#entryField').children().hide()

  showMatrix: ->
    @hideAllEntries()
    $('#entryField .matrix').show()
    $('#entryField .thumb-2d').fadeIn()

  showEntryById: (entryId) ->
    entryEl = $(".entry[data-id=#{entryId}]")
    if entryEl.exists()
      @hideAllEntries()
      entryEl.show()
    else
      @model.getHtml { id: entryId }, @callback('showEntryHtml')

  showEntryHtml: (html) ->
    @hideAllEntries()
    $('#entryField').append html
    @bindAjaxLinks '#entryField .entry:last'