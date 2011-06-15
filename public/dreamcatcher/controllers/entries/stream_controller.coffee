$.Controller 'Dreamcatcher.Controllers.Entries.Stream'

  model: {
    entry : Dreamcatcher.Models.Entry
  }

  init: (el) ->
    @showEntry = new Dreamcatcher.Controllers.Entries.ShowEntry $('#showEntry')
    @contextPanel = new Dreamcatcher.Controllers.Users.ContextPanel $('#totem') if $('#totem').exists()
    @newEditEntry = new Dreamcatcher.Controllers.Entries.NewEditEntry $('#newEditEntry')
    
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

  showStreamContext: ->
    if $('#streamContextPanel').exists()
      $('#contextPanel').hide()
      $('#streamContextPanel').show()
    else    
      @model.entry.showContext {type:'stream'}, (html) =>
        $('#contextPanel').hide()
        $('#totem').after html
        @publish 'dom.added', $('#streamContextPanel')
        @stream = new Dreamcatcher.Controllers.Entries.Stream $("#streamContextPanel")
        
  showEntryStream: ->
    $('#entryField').children().hide()
    $('#entryField .matrix.stream').show()
    @publish 'appearance.change'

  'history.entry.stream subscribe': (called, data) ->
    @showStreamContext()
    @showEntryStream()
    
  '.thumb-1d a.left, .thumb-1d a.tagCloud click': (el, ev) ->
    ev.preventDefault()
    thumbEl = el.closest('.thumb-1d')
    @historyAdd {
      controller: 'entry'
      action: 'show'
      id: thumbEl.data 'id'
      user_id: thumbEl.data 'userid'
    }
    
    
    

   
