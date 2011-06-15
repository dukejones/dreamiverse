$.Controller 'Dreamcatcher.Controllers.Stream'

  model: {
    entry : Dreamcatcher.Models.Entry
  }

  init: (el) ->
    @comments = new Dreamcatcher.Controllers.Entries.Comments $('#entryField')
    @comments.load $('#entryField')
    @showEntry = new Dreamcatcher.Controllers.Entries.Show $('#showEntry')
    @contextPanel = new Dreamcatcher.Controllers.Users.ContextPanel $('#totem') if $('#totem').exists()
    
    Stream.page = 1
    @container = $('.matrix', el)
    @activateLightBox()   
    @loadNextPage() # we want to load 2 pages on load (the first page was loaded with ruby)
    
    @bind window, 'scroll', 'scrollEvent'
    @bind $('#entry-filter, #users-filter'), 'change', 'dropdownChange'

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
    @activateLightBox()
  
  getOptions: ->
    type: $('#entry-filter').val()
    users: $('#users-filter').val()
  
  # Setup lightbox for stream
  activateLightBox: ->
    $('a.lightbox').each -> $(this).lightBox {containerResizeSpeed: 0}
    
  clear: ->
    $('#noMoreEntries, .noEntrys, #nextPageLoading, #entry-filter-wrap .spinner, #users-filter-wrap .spinner').hide()
  
  # Form listeners    
  dropdownChange: (el)->
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
    #if $('#entryField .matrix.stream').exists()
    $('#entryField').children().hide()
    $('#entryField .matrix.stream').show()
    @publish 'appearance.change'
    ###
    else
      @model.entry.showStream {}, (html) =>
        @hideEntryField()
        $('#entryField').append html
        $('#entryField .matrix.stream a.left').removeAttr 'href'
        $('#entryField .matrix.stream a.tagCloud').removeAttr 'href'
        @controller.comments.load $('entryField .matrix.stream')
    ###

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
    
    
    

   
