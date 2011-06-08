$.Controller 'Dreamcatcher.Controllers.ImageBank.ManagerSelector',

  getView: (url, data) ->
    return @view "//dreamcatcher/views/images/manager/#{url}.ejs", data

  init: ->
    @enableShiftKey()

  enableShiftKey: ->
    @shiftDown = false
    @ctrlDown = false
    $(document).keydown (event) =>
      @shiftDown = event.shiftKey
      @ctrlDown = event.altKey
      return
    $(document).keyup (event) =>
      @shiftDown = event.shiftKey
      @ctrlDown = event.altKey
      return

  #- select all/select none
  '.all click': (el) ->

    #todo: have both all and none
    if el.text().indexOf 'all' isnt -1
      $('#imagelist li').addClass 'selected'
      el.text 'select none'
    else
      $('#imagelist li').removeClass 'selected'
      el.text 'select all'

    @manager.updateMeta()

  '.clearImages click': (el) ->
    $('#imagelist').html ''

  #- select individual images

  '#imagelist li click': (el) ->
    return if el.hasClass 'uploading'
    
    if @shiftDown
      @selectRange el 

    else if @ctrlDown
      if el.hasClass 'selected'
        el.removeClass 'selected'
      else
        el.addClass 'selected'

    else
      if el.hasClass 'selected'
        el.removeClass 'selected'
      else
        $('#imagelist li').removeClass 'selected'
        el.addClass 'selected'

    @manager.updateMeta()

  selectRange: (el) ->
    firstIndex = $('#imagelist li.selected:first').index()
    lastIndex = $('#imagelist li.selected:last').index()
    currentIndex = el.index()
    fromIndex = Math.min firstIndex, currentIndex
    toIndex = Math.max lastIndex, currentIndex
    $('#imagelist li').removeClass 'selected'
    $('#imagelist li').each (i, el) =>
      $(el).addClass 'selected' if i >= fromIndex and i <= toIndex  

  #- delete individual image
  '#imagelist .close click': (el) ->
    if el.parent().hasClass 'delete'
      imageId = el.parent().data 'id'
      el.parent().hide()
    else
      el.parent().addClass 'delete'

  '.dontDelete click': (el) ->
    el.closest('li').removeClass 'delete'