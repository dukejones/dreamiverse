$.Controller 'Dreamcatcher.Controllers.Entries.DreamStream', {
  pluginName: 'dreamStream'
}, {

  model: {
    entry : Dreamcatcher.Models.Entry
  }

  init: (el) ->    
    $('#showEntry').showEntry()
    $('#newEditEntry').newEditEntry()
    $('#totem').contextPanel()
    
    Stream.page = 1
    @container = $('.matrix', el)
    @activateLightBoxAndComments()   
    @loadNextPage() # we want to load 2 pages on load (the first page was loaded with ruby)
    
    @bind window, 'scroll', 'scrollEvent'

  scrollEvent: (window)->
    return unless $('#entryField .matrix.stream').is ':visible'
    
    if (window.scrollTop() > $(document).height() - window.height() - 200)
      @loadNextPage()
    
  loadNextPage: ->
    Stream.page += 1
    Stream.load(@getOptions(), @callback('updateStream'))

    @clear()
    $('#nextPageLoading').show()
    
  updateStream: (json) ->
    @clear()
    
    if not json.html? or json.html is ""
      Stream.noMore()
      $('#noMoreEntries').show() # No more entries to load.
    
    @container.empty() if Stream.page == 1
    @container.append json.html
    @activateLightBoxAndComments()
  
  getOptions: ->
    type: $('#entry-filter').val()
    users: $('#users-filter').val()
  
  # Setup lightbox for stream
  activateLightBoxAndComments: ->
    $('a.lightbox').each -> $(this).lightBox {containerResizeSpeed: 0}
    $('.thumb-1d').each -> $(this).comments() unless $(this).hasClass 'dreamcatcher_common_comments' 
    
  clear: ->
    $('#noMoreEntries, .noEntrys, #nextPageLoading, #entry-filter-wrap .spinner, #users-filter-wrap .spinner').hide()
  
  '#entry-filter, #users-filter change': (el)->
    Stream.reset()
    el.prev(".spinner").show()
    Stream.load @getOptions(), @callback('updateStream')


  'entries.stream subscribe': ->
    $('#entryField').children().hide()
    $('#entryField .matrix.stream').show()
    $('#totem').hide()
    $('#streamContextPanel').show()
    @publish 'appearance.change'
    
  ###  
  '.thumb-1d a.left, .thumb-1d a.tagCloud click': (el, ev) ->
    ev.preventDefault()
    @publish 'entry.show', el.attr 'href'
  ###
}
    
    
    

   
