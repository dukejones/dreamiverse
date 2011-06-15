$.Controller 'Dreamcatcher.Controllers.Entries.NewEditEntry', {
  pluginName: 'newEditEntry'
}, {

  model: {
    entry : Dreamcatcher.Models.Entry
  }

  init: ->
    @initCookieSaver()
    
  #-
  displayNewEditEntry: (html) ->
    $('#entryField').children().hide()
    $('#newEditEntry').html html

    $('#newEditEntry .entry-tags').tags 'edit' # invoke the tags controller
    
    if @mode is 'new' and $('#contextPanel .book').exists()
      bookId = $('#contextPanel .book').data 'id'
      $('#contextPanel .book').remove()
      $('#books-list').val bookId  
    
    @publish 'dom.added', $('#newEditEntry')
    log 'book val'+$('#books-list').val()
    $('#book-list-button').css {
      width: '32px'
    }
    $('#newEditEntry').show()
    

  newEntry: ->
    @mode = 'new'
    @model.entry.new {}, @callback('displayNewEditEntry')

  'entry.new subscribe': ->
    window.history.pushState 'entry.new', 'New Entry', '/entries/new'
    @publish 'context_panel.show'
    @newEntry()

  #'history.entry.new subscribe': (called, data) ->

  editEntry: (id) ->
    @mode = 'edit'
    @model.entry.edit {id: id}, @callback('displayNewEditEntry')

  'history.entry.edit subscribe': (called, data) ->
    @publish 'context_panel.show', data.user_id if data.user_id?
    @editEntry data.id
    
  #- 
  'form#new_entry, form.edit_entry submit': (el, ev) ->
    ev.preventDefault()
    new Dreamcatcher.Models.Entry(el.formParams()).save()
   
  'entry.created subscribe': (called, response) ->
    log response.type
    if response.type is 'error'
      log 'oh no!'
    else if response.type is 'ok'
      @publish 'entry.show', response.data.id #check


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
    
  #-  
  '#books-list change': (el) ->
    $('#books-list-button').css {
      'width': '150px'
    }
    if el.val() is 'new'
      inputEl = $('input.newBook-input', el.parent())
      inputEl.val ''
      inputEl.show()
      $('.books-list-button').hide()
    else
      $('input.newBook-input', el.parent()).hide()
      $('.ui-selectmenu-status', el.parent()).show()
    
  '.entryPanels .headers click': (el) ->
    entryPanelEl = el.closest '.entryPanels'
    name = entryPanelEl.attr 'title'
    entryPanelEl.hide()
    $("#entryAttach .attach[title=#{name}]").show()
  
  '#entryAttach .attach click': (el) ->
    name = el.attr 'title'
    el.hide()
    $(".entryPanels[title=#{name}]").show()
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
        list: 'currentImages'
      }
    }, '//dreamcatcher/views/images/entry/image_show.ejs'
    
}
    





  





