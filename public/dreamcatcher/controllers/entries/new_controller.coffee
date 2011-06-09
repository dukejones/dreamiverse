$.Controller 'Dreamcatcher.Controllers.Entries.New',
  
  fields: ['#entry_title','#entry_body','#sharing-list','#entryType-list']
  interval: 5000
  
  helper: {
    upload: Dreamcatcher.Classes.UploadHelper
  }

  init: ->
    #$('#new_entry').removeAttr 'method'
    #$('#new_entry').removeAttr 'action'
    #$('#new_entry').removeAttr 'accept-charset'
    
    @entryCookie = new Dreamcatcher.Classes.CookieHelper "dc_new_entry",true
    @currentEntryType = $('#entryMode').data 'id'
    @posted = false
    @retrieveState()
    @saveState()
    @createUploader()
       
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
    if el.val() is '+ new book'
      $('input.newBook-input', el.parent()).show()
      $('.ui-selectmenu-status', el.parent()).hide()
    else
      $('input.newBook-input', el.parent()).hide()
      $('.ui-selectmenu-status', el.parent()).show()
      
    $('#books-list-button').css 'width',''
  
  '#entryAttach .attach click': (el) ->
    name = (el.attr 'id').replace('attach-','')
    $(".entry-#{name}").show()
    
  '.headers click': (el) ->
    el.parent().hide()
    
  'form#new_entry submit': (el) ->
    log 'x'
    
    
  createUploader: ->
    @upload = new Dreamcatcher.Controllers.Common.Upload $('#imageDropArea')
    @upload.load $('#imageDropArea'), false, {
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
    ###
    @filesUploaded = 0
    return @helper.upload.create $('#imageDropArea'), false, 
    ###


  





