$.Controller 'Dreamcatcher.Controllers.Entry',
  
  fields: ['#entry_title','#entry_body','#sharing_select','#entryType_list']
  interval: 5000
  
  init: ->
    @entryCookie = new Dreamcatcher.Classes.CookieHelper 'dc_new_entry',true
    @retrieveState()
    @saveState()
    
  saveState: ->
    entry = {}
    entry[field] = $(field).val() for field in @fields
    @entryCookie.set entry
    setTimeout =>
      @saveState()
    , @interval
  
  retrieveState: ->
    entry = @entryCookie.get()
    if entry? and confirm 'you have an unsaved entry.\n\nwould you like to bring it back ?'
      for field in @fields
        $(field).val entry[field]
        @clearState()
  
  clearState: ->
    @entryCookie.clear()
  
  '#entry_submit click': ->
    @entryCookie.clear()
