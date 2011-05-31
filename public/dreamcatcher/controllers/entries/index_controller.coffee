$.Controller 'Dreamcatcher.Controllers.Entries.Index',
  
  model: Dreamcatcher.Models.Entry

  hash: (entryId) ->
    if entryId.toString().trim().length is 0
      @showMatrix()
    else
      @showEntryById entryId
      
  bindAjaxLinks: (parent) ->
    $('a.history', parent).each (i, el) =>
      href = $(el).attr 'href'
      if href.indexOf '#' is -1
        entryId = href.split('/').pop()
        entryId = parseInt entryId
        if entryId.toString() isnt 'NaN'
          $(el).attr 'href', "##{entryId}"
        else
          $(el).attr 'href', "#"
  
  init: ->
    @bindAjaxLinks '#entryField .matrix'
    $.history.init @callback('hash')

  'a[@rel=history] click': (el) ->
    entryId = parseInt el.attr('href').replace(/^.*#/, '')
    $('#entryField .thumb-2d').each (i, el) =>
      id = parseInt $(el).data 'id'
      $(el).fadeOut 'fast' if id isnt entryId
    $.history.load entryId
    @showEntryById entryId
    return false
    
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

    
        