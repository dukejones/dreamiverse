$.Controller 'Dreamcatcher.Controllers.Entries.Show',

  'a.spine-nav click': (el) ->
    @historyAdd
      controller: 'book'
      action: 'show'
      id: el.data 'id'
      
  '.stream click': ->
    @historyAdd {
      controller: 'entry'
      action: 'stream'
    }
    
  '.prev, .next click': (el) ->
    @historyAdd {
      controller: 'entry'
      action: 'show'
      id: el.data 'id'
    }
    
  '.editEntry click': (el) ->
    @historyAdd {
      controller: 'entry'
      action: 'edit'
      id: el.closest('.entry').data 'id'
    }
  
  
  
