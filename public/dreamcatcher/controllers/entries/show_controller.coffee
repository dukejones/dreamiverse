$.Controller.extend 'Dreamcatcher.Controllers.Entries.Show',

  'a.spine-nav click': (el) ->
    @historyAdd
      controller: 'book'
      action: 'show'
      id: el.data 'id'
      
  '.stream click': ->
    @historyAdd {
      controller: 'entry'
      action: 'field'
    }
    
  '.prev, .next click': (el) ->
    @historyAdd {
      controller: 'entry'
      action: 'show'
      id: el.data 'id'
    }
  
  
  
