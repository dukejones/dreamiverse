$.Controller 'Dreamcatcher.Controllers.Entries.NewEntry',
  
  init: ->
    @initCookieSaver()
      
      
  'form#new_entry submit': (el, ev) ->
    ev.preventDefault()
    new Dreamcatcher.Models.Entry(el.formParams()).save()
   
  'entry.created subscribe': (called, response) ->
    if response.type is 'error'
      log 'oh no!'
    #else if response.type = 'ok'
    #show entry with response.data.entry_id


  #- Cookie Saver
      
  fields: ['#entry_title','#entry_body','#sharing-list','#entryType-list']
  interval: 5000
  
  initCookieSaver: ->
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
    
      
  '#books-list change': (el) ->
    $('#books-list-button').css {
      #width: 'auto !important'
      'width': '160px !important' # TODO: remove
    }
    if el.val() is '+ new book'
      $('input.newBook-input', el.parent()).show()
      $('.ui-selectmenu-status', el.parent()).hide()
    else
      $('input.newBook-input', el.parent()).hide()
      $('.ui-selectmenu-status', el.parent()).show()
    
  '.headers click': (el) ->
    el.parent().hide()
  
  '#entryAttach .attach click': (el) ->
    name = (el.attr 'id').replace('attach-','')
    el.hide()
    $(".entry-#{name}").show()
    @initUploader() if name is 'images'
      
  initUploader: ->
    $('#imageDropArea').uploader {
      listElement: null
      params: {
        image: {
          section: 'entry'
          category: ''
          genre: ''
        }
      }
      classes: {
        button: 'clickToBrowse'
        drop: 'dropboxBrowse'
        active: 'qq-upload-drop-area-active'
        list: 'dropboxImages'
      }
    }
    





  





