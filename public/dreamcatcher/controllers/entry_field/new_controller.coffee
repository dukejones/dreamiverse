$.Controller 'Dreamcatcher.Controllers.Entries.New',
  
  fields: ['#entry_title','#entry_body','#sharing-list','#entryType-list']
  interval: 5000

  init: ->
    @entryCookie = new Dreamcatcher.Classes.CookieHelper "dc_new_entry",true
    @currentEntryType = $('#entryMode').data 'id'
    @posted = false
    @retrieveState()
    @saveState()
       
  saveState: ->
    return if @posted
    if @currentEntryType is 'new' 
      entryBody = $('#entry_body').val().trim()
      if entryBody.length > 0 
        entry = {}  
        entry['type'] = $('#entryMode').data 'id'
        entry['id'] = $('#entryId').data 'id'
        entry[field] = $(field).val() for field in @fields
        entry['#currentImages'] = $('#currentImages').html()
        @entryCookie.set entry
      setTimeout =>
        @saveState()
      , @interval
  
  retrieveState: ->
    entry = @entryCookie.get() 
    
    if entry? and @currentEntryType is 'new'     
      $(field).val entry[field] for field in @fields
      $('#currentImages').html entry['#currentImages']
      @stateRetrieved = true
      unless confirm 'keep this un-saved entry?'
        @clearForm()
        
    @clearState()         

  clearForm: ->
    $(field).val '' for field in @fields
    $('#currentImages').html ''
        
  clearState: ->
    @entryCookie.clear()
  
  '#entry_submit click': ->
    @posted = true
    @clearState()
    





