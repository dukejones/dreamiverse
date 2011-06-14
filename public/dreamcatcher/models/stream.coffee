$.Model 'Stream',{
    
  load: (filters, success) ->
    return if @currentlyLoading
    $.extend(filters, {page: @page})

    @currentlyLoading = true
    $.get('/stream.json', {filters: filters}, success).done =>
      @currentlyLoading = false
      
  noMore: ->
    @currentlyLoading = true
    
  reset: ->
    @page = 1
    @currentlyLoading = false
},
{}