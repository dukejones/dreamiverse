$.Controller 'Dreamcatcher.Controllers.Entries.Index',
  
  model: Dreamcatcher.Models.Entry

  hash: (entryId) ->
    if entryId.trim().length is 0
      @showMatrix()
    else
      @showEntryById entryId
      
  bindAjaxLinks: (parent) ->
    $('a.history', parent).each (i, el) =>
      href = $(el).attr 'href'
      if href.indexOf '#' is -1
        entryId = href.split('/').pop()
        $(el).attr 'href', "##{entryId}"
  
  init: ->
    @bindAjaxLinks '#entryField .matrix'
    $.history.init @callback('hash')

  'a[@rel=history] click': (el) ->
    entryId = el.attr('href').replace(/^.*#/, '')
    $.history.load entryId
    @showEntryById entryId
    return false
    
  hideAllEntries: ->
    $('#entryField').children().hide()
  
  showMatrix: ->
    @hideAllEntries()
    $('#entryField .matrix').show()

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

    
        