$.Controller 'Dreamcatcher.Controllers.Users.ContextPanel',

  '.avatar, .book click': (el) ->
    if el.hasClass('book') and $('#showEntry').is(':visible')
      @historyAdd {
        controller: 'book'
        action: 'show'
        id: el.data 'id'
      }
    else
      @historyAdd {
        controller: 'entry'
        action: 'field'
      }