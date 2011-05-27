$.Controller 'Dreamcatcher.Controllers.ImageBank.Manager',

  imageModel: Dreamcatcher.Models.Image
  ibModel: Dreamcatcher.Models.ImageBank
  
  getView: (url, data) ->
    return @view "//dreamcatcher/views/image_bank/manager/#{url}.ejs", data

  init: ->
    @populateLists()
    @initUploader()
    @enableShiftKey()
    
  isDropbox: ->
    return $('frame.manager h1').text() is 'Drop box'
      
  close: ->
    @parent.setDropboxImages $('#imagelist li') if @isDropbox()
    @parent.showBrowser true
    
    $("#frame.manager").hide()
    
  show: (images, title) ->
    $("#frame.manager h1").text title if title?
    @showImages images if images?
    $("#frame.manager").show()
      
    
  enableShiftKey: ->
    @shiftDown = false
    @ctrlDown = false
    $(document).keydown (event) =>
      @shiftDown = event.shiftKey
      @ctrlDown = event.altKey
      return
    $(document).keyup (event) =>
      @shiftDown = event.shiftKey
      @ctrlDown = event.altKey
      return
      
      
  ##- File Uploader

  initUploader: ->
    params = {
      elementId: '#uploader'
      url: '/images.json'
      fileTemplate: @getView 'image_upload'
    }
    @uploader = Dreamcatcher.Classes.UploadHelper.createUploader params, @callback('uploadSubmit'), @callback('uploadComplete'), @callback('uploadCancel'), @callback('uploadProgress')
  
  '#uploader .browse click': (el) ->
    @uploader.setParams @getOrganizationMeta()
    
  getImageElement: (imageId) ->
    return $("#imagelist li[data-id=#{imageId}]")
  
  uploadSubmit: (id, fileName) ->
    if @replaceImageId?
      el = @getImageElement @replaceImageId
      el.replaceWith @getUploadElement fileName
    
  uploadComplete: (id, fileName, result) ->
    @replaceImageId = null
    @uploader.setParams @getOrganizationMeta()
    
    if result? and result.image?
      @showImage result.image, @getUploadElement fileName
      if @isDropbox() #todo: test
        el = @getImageElement result.image.id
        @parent.addImageToDropbox result.image.id
  
  uploadCancel: (id, fileName) ->
    el = @getUploadElement fileName
    el.remove()
  
  uploadProgress: (id, fileName, loaded, total) ->
    log loaded
    log total

  getUploadElement: (fileName) ->
    return $("#imagelist li .file:contains('#{fileName}')").closest('li')


  #- Organization Lists

  populateLists: ->
    for type in @ibModel.types
      $("#type select").append("<option data-categories='#{JSON.stringify type.categories}'>#{type.name}</option>")
    for genre in @ibModel.genres
      $("#genre select").append("<option>#{genre}</option>")

      
  #- gets the type, category & genre meta (for new uploaded images)
  
  getOrganizationMeta: ->
    image = {}
    $("#organization select").each (i, el) =>
      attr = $(el).parent().attr 'id'
      value = $(el).val()
      image[attr] = if value.length > 0 then value else null
    image.section = image.type
    return { image: image }
      

  #- loads all meta for a list of images
  showImages: (images) ->
    $("#imagelist").html ''
    @showImage image for image in images
    
  #- add image Html to the Dom
  showImage: (image, replaceElement) ->
    html = @getView 'image_show', image
    if replaceElement?
      replaceElement.replaceWith html
    else
      $("#imagelist").append html

  ## [ IMAGE META ] ##
  #- show only the common meta for all the selected images
  #- if only one is selected, then show all that comments meta
  showCommonImageMetaData: ->
    commonMeta = {}
    $('#imagelist li.selected').each (i, el) =>
      imageMeta = $(el).data 'image' 
      
      #- special cases, such as date and user (i.e. needs to be converted from raw json)
      imageMeta.date = $.format.date imageMeta['created_at'].replace('T',' '), 'MMM dd, yyyy'
      imageMeta.user = 'phong'
      imageMeta.type = imageMeta.section
      
      for attr in @ibModel.attributes
        if not commonMeta[attr]?
          commonMeta[attr] = imageMeta[attr]
        else if commonMeta[attr] isnt imageMeta[attr]
          commonMeta[attr] = '*'
    @displayMetaData commonMeta
    

  #- display's the meta data for a particular image object
  displayMetaData: (image) ->
    for attribute in @ibModel.attributes
      @displayAttribute attribute, image[attribute] 
  
  #- checks if an attribute is of type "text"
  isText: (attr) ->
    return $("##{attr} input[type=text]").exists()

  #- checks if an attribute is of type "select"
  isSelect: (attr) ->
    return $("##{attr} select").exists()
  
  #- sets the text input or select to display a certain value
  displayAttribute: (attr, value) ->
    $("##{attr} input[type=checkbox]").attr('checked', value? and value isnt "*")
    if @isText attr
      if value is "*"
        $("##{attr} input[type=text]").val('').attr 'placeholder', 'different'
      else
        $("##{attr} input[type=text]").val(value).removeAttr 'placeholder'
    else if @isSelect attr
      $("##{attr} select").val(value).change()
    else
      $("##{attr} textarea").val value
  
  ## [ DOM EVENTS ] ##
  
  '.browseWrap click': ->
    @close()
    
  #- select all/select none
  '.all click': (el) ->
  
    #todo: have both all and none
    if el.text().indexOf 'all' isnt -1
      $('#imagelist li').addClass 'selected'
      el.text 'select none'
    else
      $('#imagelist li').removeClass 'selected'
      el.text 'select all'
      
    @showCommonImageMetaData()

  '.clearImages click': (el) ->
    $('#imagelist').html ''
    
  #- select individual images

  '#imagelist li click': (el) ->
    if @shiftDown
      @selectRange el 
      
    else if @ctrlDown
      if el.hasClass 'selected'
        el.removeClass 'selected'
      else
        el.addClass 'selected'
        
    else
      if el.hasClass 'selected'
        el.removeClass 'selected'
      else
        $('#imagelist li').removeClass 'selected'
        el.addClass 'selected'

    @showCommonImageMetaData()
  
  selectRange: (el) ->
    firstIndex = $('#imagelist li.selected:first').index()
    lastIndex = $('#imagelist li.selected:last').index()
    currentIndex = el.index()
    fromIndex = Math.min firstIndex, currentIndex
    toIndex = Math.max lastIndex, currentIndex
    $('#imagelist li').removeClass 'selected'
    $('#imagelist li').each (i, el) =>
      $(el).addClass 'selected' if i >= fromIndex and i <= toIndex  
    
  #- delete individual image
  '#imagelist .close click': (el) ->
    if el.parent().hasClass 'delete'
      imageId = el.parent().data 'id'
      el.parent().hide()
    else
      el.parent().addClass 'delete'

      
  '#imagelist .replace click': (el) ->
    @replaceImageId = el.parent().data 'id'
    @uploader.setParams { id: @replaceImageId }
    $('#uploader .browse input[type=file]').click()
  
  '.dontDelete click': (el) ->
    el.closest('li').removeClass 'delete'

  #- "category" input (select) change
  '#type select change': (el) ->
    $('#category select option[class!=label]').remove()
    if el.val().length > 0
      for category in $('option:selected',el).data 'categories'
        $('#category select').append "<option>#{category}</option>"

  #- input (select, text) focus
  'input[type=text], select focus': (el) ->
    $('input[type=checkbox]', el.parent()).attr 'checked', true
    
    
  'select change': (el) ->
    @uploader.setParams @getOrganizationMeta()

  #- input (select, text) blur - update Meta
  'input[type=text], textarea, select blur': (el) ->
    value = el.val().trim()
    value = value.replace /'/gi, '`'
    doUpdate = value.length > 0
    $('input[type=checkbox]', el.parent()).attr 'checked', doUpdate
    return if not doUpdate
    attribute = el.parent().attr 'id' 
    $('#imagelist li.selected').each (i, el) =>
      meta = $(el).data 'image'
      meta[attribute] = value
      $(el).data 'image', meta


  #- resets all data to original
  '.reset click': (el) ->
    $("#imagelist li").removeClass 'selected'
    @displayMetaData {}
    $('#imagelist li').each (i, el) =>
      imageId = $(element).data 'id'
      @imageModel.get imageId, {}, (imageMeta) =>
        $(el).data 'image', imageMeta
      $(el).show()
      
  #- saves all data and goes back to ib_browser
  '.save click': (el) ->
    @showSavingSpinner()
    
    @totalToSave = $('#imagelist li').length
    @totalSaved = 0
  
    $('#imagelist li').each (i, el) =>
      imageId = $(el).data 'id'
      imageMeta = @getMetaToSave $(el)
      if $(el).is ":visible"
        @imageModel.update imageId, {image: imageMeta}, @closeOnAllSaved()
      else
        @imageModel.disable imageId, {}, @closeOnAllSaved()
        
  getMetaToSave: (el) ->
    imageMeta = el.data 'image'
    delete imageMeta.date
    delete imageMeta.user
    imageMeta.section = imageMeta.type
    return imageMeta
    
  closeOnAllSaved: ->
    @totalSaved++
    if @totalToSave is @totalSaved
      @hideSavingSpinner()
      @close()
          
  showSavingSpinner: ->
    $(".save span").hide()
    $(".save .spinner, .save .saving").show()
  
  hideSavingSpinner: ->
    $(".save span").show()
    $(".save .spinner, .save .saving").hide()

  #- cancels all data changes and goes back to ib_browser
  '.cancel click': (el) ->
    $('#imagelist').html ''
    @close()
    
  ###