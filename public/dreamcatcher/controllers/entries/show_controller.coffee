$.Controller 'Dreamcatcher.Controllers.Entries.Show',

  controller: {}
  
  model: {
    entry : Dreamcatcher.Models.Entry
    #user: Dreamcatcher.Models.User
  }

  el: { 
    entry: (id) ->
      return $("#showEntry .entry[data-id=#{id}]")
  }

  init: ->
    @controller.comments = new Dreamcatcher.Controllers.Entries.Comments $('#entryField')

  showEntryById: (id) ->
    entryEl = @el.entry id
    log 'showEntryById'
    $('#showEntry').tags 'show' # invoke the tags controller
    if entryEl.exists()
      @showEntryElement entryEl
    else
      @model.entry.show {id: id}, (html) =>
        $('#showEntry').append html
        @showEntryElement @el.entry id
        showEntryEl = $('#showEntry .entry:last')
        @controller.comments.load showEntryEl
        showEntryEl.linkify().videolink()

  showEntryElement: (entryEl) ->
    $('#showEntry').children().hide()
    $('#entryField').children().hide()
    $('#showEntry').show()
    entryEl.show()
    @publish 'appearance.change', entryEl.data 'viewpreference'
  
  'history.entry.show subscribe': (called, data) ->
    @publish 'context_panel.show', data.user_id if data.user_id?
    @showEntryById data.id
    

  'a.spine-nav click': (el, ev) ->
    ev.preventDefault()
    @historyAdd
      controller: 'book'
      action: 'show'
      id: el.data 'id'

  '.stream click': (el, ev) ->
    ev.preventDefault()
    @historyAdd {
      controller: 'entry'
      action: 'stream'
    }
    
  '.entries click': (el, ev) ->
    ev.preventDefault()
    @historyAdd {
      controller: 'entry'
      action: 'field'
    }
    
  '.prev, .next click': (el, ev) ->
    ev.preventDefault()
    @historyAdd {
      controller: 'entry'
      action: 'show'
      id: el.data 'id'
    }
    
  '.editEntry click': (el, ev) ->
    ev.preventDefault() #todo: uncomment href in haml
    @historyAdd {
      controller: 'entry'
      action: 'edit'
      id: el.closest('.entry').data 'id'
    }
  
  
  
