$.Controller 'Dreamcatcher.Controllers.Entries.NewEditEntry', {
  pluginName: 'newEditEntry'
}, {

  init: (el) ->
    @element = $(el)
    @element.tags 'edit' # invoke the tags controller
    @initCookieSaver()
    @initBooksListButton()
    
  initBooksListButton: ->
    $('#books-list-button').css {
      width: '32px'
    }

  displayNewEditEntry: (html) ->
    $('#entryField').children().hide()
    @element.html html
    
    if @mode is 'new' and $('#contextPanel .book').exists()
      bookId = $('#contextPanel .book').data 'id'
      $('#contextPanel .book').remove()
      $('#books-list').val bookId  
    
    @publish 'app.initUi', @element
    @initBooksListButton()
    @element.fadeIn '500', =>
      fitToContent $('textarea', @element).attr('id'), 0
    

  'entries.new subscribe': ->
    @publish 'context_panel.show'
    @mode = 'new'
    Entry.new {}, @callback('displayNewEditEntry')

  'entries.edit subscribe': (called, data) ->
    log 'x'
    @publish 'context_panel.show'
    @mode = 'edit'
    Entry.edit data.id, @callback('displayNewEditEntry')
    
  #- Cookie Saver
      
  fields: ['#entry_title','#entry_body','#sharing-list','#entryType-list']
  interval: 5000
  
  initCookieSaver: ->
    @entryCookie = new CookieHelper "dc_new_entry", true
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
  
  '#entry_submit click': (el) ->
    @posted = true
    @clearState()
    el.attr('disabled',true)
    
  '#books-list change': (el) ->
    $('#books-list-button').css {
      'width': '150px'
    }
    $('#books-list-button').removeClass('book bookSpine')
    if el.val() is 'new'
      inputEl = $('input.newBook-input', el.parent())
      inputEl.show()
      inputEl.focus()
      $('#books-list-button').css {
        'width': '28px'
      }
      $('.ui-selectmenu-status', el.parent()).hide()
    else
      $('input.newBook-input', el.parent()).hide()
      $('.ui-selectmenu-status', el.parent()).show()
      
  '#entry-date click': (el) ->
    $('.entry-dateTime', @element).slideDown()
  
    
  '.headers click': (el) ->
    entryPanelEl = el.closest '.entryPanels'
    name = entryPanelEl.attr 'name'
    entryPanelEl.hide()
    $("#entryAttach .attach[name=#{name}]").show()
  
  '#imagesHeader click': (el) ->
    $(".entryImages").slideUp()
  
  ##entryAttach 
  '.attach click': (el) ->
    name = el.attr 'name'
    if name? and name.length > 0
      $(".entryPanels[name=#{name}]").slideDown 'fast', => el.hide()
      @initUploader() if name is 'images'
      
  initUploader: ->
    $('#imageUpload.uploader').uploader {
      #listElement: null
      params: {
        image: {
          section: 'entry'
          category: ''
          genre: ''
        }
      }
      #classes: {
      #button: 'clickToBrowse'
      #drop: 'dropboxBrowse'
      #active: 'qq-upload-drop-area-active'
      #list: 'currentImages'
      #}
    }, '/dreamcatcher/views/images/entry/image_show.ejs'
    
    
  ###
  'form#new_entry, form.edit_entry submit': (el, ev) ->
    ev.preventDefault()
    new Entry(el.formParams()).save()


  'entry.created subscribe': (called, response) ->
    log response.type
    if response.type is 'error'
      log 'oh no!'
    else if response.type is 'ok'
      @publish 'entry.show', response.data.id #check
  ###
    
    
}
    





  





