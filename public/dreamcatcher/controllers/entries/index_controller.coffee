$.Controller 'Dreamcatcher.Controllers.Entries.Index',
  
  model: Dreamcatcher.Models.Entry

  hash: (hash) ->
    if hash.trim().length is 0
      @showMatrix()
    else
      @showEntryId hash
  
  init: ->
    $.history.init @callback('hash')
    
    $('.thumb-2d a.link').each (i, el) =>
      href = $(el).attr 'href'
      entryId = href.split('/').pop()
      $(el).attr 'href', "##{entryId}"

  'a[@rel=history] click': (el) ->
    entryId = el.attr('href').replace(/^.*#/, '')
    $.history.load entryId
    @showEntryId entryId
    return false
    
  showMatrix: ->
    $('#entryField').children().hide()
    $('#entryField .matrix').show()

  showEntryId: (entryId) ->
    #todo check dom for entry, show it, instead of loading it again
    @model.getHtml { id: entryId }, @callback('showEntryHtml')

  showEntryHtml: (html) ->
    $('#entryField').children().hide()
    $('#entryField').append html

    
        