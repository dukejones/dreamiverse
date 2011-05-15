
$(document).ready ->
  streamController = new StreamController()
  streamController.streamView.loadNextPage()


class StreamController
  constructor: ->
    log 'running StreamController constructor: '
    @stream = new StreamModel()
    @streamView = new StreamView(@stream)

    # $.subscribe 'filter:change', => 
    #   @stream.load().then (data) =>
    #     @streamView.update(data.html)

    $('#entry-filter, #users-filter').change( (event) =>
      @stream.load().then (data) =>
        @streamView.update(data.html)
    )
    


class StreamView
  constructor: (streamModel)->
    log 'running StreamView constructor:'
    @page = 1
    @stream = streamModel
    @$container = $('#entryField .matrix')
    @activateLightBox()
    # adds the loading wheel
    #entry-filter-wrap
    $('#entry-filter, #users-filter').change( (event) =>
      $('#entry-filter-wrap .spinner').show() if event.currentTarget.id is 'entry-filter'
      $('#users-filter-wrap .spinner').show() if event.currentTarget.id is 'users-filter'
    )
        
    # $('.filterList').click( (event) =>
    #   $(event.currentTarget).parent().find('.trigger').addClass('loading')
    # )
    
    # infinite scrolling
    $(window).scroll =>
      if ($(window).scrollTop() > $(document).height() - $(window).height() - 200)
        @loadNextPage()
  clear: ->
    $('#noMoreEntries, .noEntrys, #nextPageLoading').hide()
  activateLightBox: ->
    # Setup lightbox for stream
    $('a.lightbox').each((i, el) ->
      $(this).lightBox({containerResizeSpeed: 0});
    )
  loadNextPage: ->
    return if @currentlyLoading
    @currentlyLoading = true
    @clear()
    $('#nextPageLoading').show()
    @page += 1
    @stream.load({ page: @page }).then (data)=>
      @clear()
      @currentlyLoading = false
      if !data.html? || data.html == ""
        @currentlyLoading = true # No more entries to load.
        $('#noMoreEntries').show()
        
      @$container.append(data.html)
      @activateLightBox()
  update: (html) ->
    log 'running StreamView update:'
    @clear()
    if html == ''
      $('.noEntrys').show()

    # after data loads into view, remove the loading spinner
    # $('#streamContextPanel .trigger').removeClass('loading')
    # and hide the filter spinners
    $('#entry-filter-wrap .spinner, #users-filter-wrap .spinner').hide()

    @$container.html(html)
    @activateLightBox()
    


class StreamModel
  load: (filters={})->
    log 'running StreamModel load'
    @updateFilters()
    $.extend(filters, @filterOptions())
    $.getJSON("/stream.json", {filters: filters}).promise()  
  updateFilters: ->
    # @entryFilter = $('#entry-filter').val()
    # @usersFilter = $('#users-filter').val() 
       
    @entryFilter = $('#entry-filter').val()
    @usersFilter = $('#users-filter').val()    
    
    # we don't want filters for all
    @entryFilter = '' if @entryFilter == 'all entries'
    @usersFilter = '' if @usersFilter == 'all users'
    
    log '@entryFilter: ' + @entryFilter
    log '@usersFilter: ' + @usersFilter   

  filterOptions: ->
    type: @entryFilter
    users: @usersFilter
    # starlight: @filters[2]