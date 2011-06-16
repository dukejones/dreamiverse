$.Controller 'Dreamcatcher.Controllers.Entries.DreamField', {
  pluginName: 'dreamField'
}, {

  model: {
    entry : Dreamcatcher.Models.Entry
  }
  
  data: (el) ->
    return el.data type if type?
    return el.data 'id' if el?
    return null
    
  #- constructor
  
  init: (el) ->
    @element = $(el)    
    @publish 'entry.drag', @element
          
  #- move entry to book (drag & drop)
  
  'entry.drag subscribe': (called, parent) ->
    $('.thumb-2d', parent).draggable {
      containment: 'document'
      zIndex: 100
      revert: false
      helper: 'clone'
      revertDuration: 100
      start: (ev, ui) =>
        @toggleBookContext true
      stop: (ev, ui) =>
        @toggleBookContext false
        
    }
  
  #- hides the book if it sits in the context menu
  
  toggleBookContext: (start) ->
    unless @element.is ':visible'
      $('#contextPanel .book').toggle not start
      $('#contextPanel .avatar').toggle start
  
  #- entry field
  
  hideEntryField: ->
    $('#entryField').children().hide()
  
  showEntryField: (username) ->
    if @element.data('username') is username
      @hideEntryField()
      $('.book, .thumb-2d', @element).show().css 'opacity',''
      $('.matrix.books, .matrix.index').fadeIn 500
      @publish 'appearance.change'
      return
      
    @model.entry.index username, (html) =>
      @hideEntryField()
      $('.matrix.books').remove()
      @element.replaceWith html
      $('.matrix.books').books() 
      $('.matrix.books, .matrix.index').fadeIn 500
      @publish 'appearance.change'
    
    
  'entries.index subscribe': (called, data) ->
    username = if data.username? then data.username else null
    @publish 'context_panel.show', username
    @showEntryField username
    
}
  
