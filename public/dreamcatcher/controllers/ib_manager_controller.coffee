$.Controller 'Dreamcatcher.Controllers.IbManager',

  model: Dreamcatcher.Models.ImageBank
  
  init: ->
    @imageCookie = new Dreamcatcher.Classes.CookieHelper("imagebank")
    @populateLists()
    @createUploader()
    
    album = $.query.get 'album'
    if album.length > 0
      @loadAlbumImages album
    else
      @loadImages @imageCookie.getAll()
  

  ## [ IMAGE FILE UPLOADER ] ##

  createUploader: ->
    @uploader = new qq.FileUploader {
      element: $('#uploader').get(0)
      action: '/images.json'
      maxConnections: 1
      params: @getOrganizationMeta()
      debug: true
      onSubmit: (id, fileName) ->
        log "Submitted: "+id+' '+fileName
      onComplete: (id, fileName, result) =>
        image_url = result.image_url
        image = result.image
        @showImage $("#imagelist li .file:contains('#{fileName}')").closest('li'),image
      template: $("#uploader").html()
      fileTemplate: @view('fileTemplate')
      classes: {
        button: 'browse'
        drop: 'dropArea'
        dropActive: 'active'
        list: 'imagelist'
        progress: 'progress'
        file: 'file'
        spinner: 'spinner'
        size: 'size'
        cancel: 'cancel'
        success: 'success'
        fail: 'fail'
      }
    }

    
  #- populates the organization lists with seed date
  populateLists: ->
    for type in @model.types
      $("#type select").append("<option>#{type.name}</option>")
      $("#type select option:last").data("categories",type.categories)
    for genre in @model.genres
      $("#genre select").append("<option>#{genre}</option>")

  #- loads all meta for a list of images
  loadImages: (imageIds) ->
    @model.findImagesById imageIds.join(','),{},@callback('showImages')
    
  loadAlbumImages: (album) ->
    @model.searchImages {q: album, album: album},@callback('showImages')

  showImages: (images) ->
    $("#imagelist").append @view('list',{images: images})
    
  #- add image Html to the Dom
  showImage: (uploadElement, image) ->
    imageHtml = @view 'show',image
    if uploadElement?
      uploadElement.replaceWith imageHtml
    #else
    #  $("#imagelist").append imageHtml

  
  ## [ IMAGE META ] ##
  
  #- gets the type, category & genre meta (for new uploaded images)
  getOrganizationMeta: ->
    image = {}
    $("#organization select").each (index,element) =>
      attr = $(element).parent().attr("id")
      val = $(element).val()
      image[attr] = if val.length > 0 then val else null
    image.section = image.type
    return {image: image}
    
  #- show only the common meta for all the selected images
  #- if only one is selected, then show all that comments meta
  showCommonImageMetaData: ->
    common = {}
    $("#imagelist li.selected").each (index, element) =>
      data = $(element).data 'image'
      
      #- special cases, such as date and user (i.e. needs to be converted from raw json)
      data.date = $.format.date(data["created_at"].replace("T"," "), 'MMM dd, yyyy')
      data.user = "phong"
      data.type = data.section
      
      for attr in @model.attributes
        if not common[attr]?
          common[attr] = data[attr]
        else if common[attr] isnt data[attr]
          common[attr] = '*'
    @displayMetaData(common)

  #- display's the meta data for a particular image object
  displayMetaData: (image) ->
    @setAttribute(attribute,image[attribute]) for attribute in @model.attributes
  
  #- checks if an attribute is of type "text"
  isText: (attr) ->
    return $("##{attr} input[type='text']").exists()

  #- checks if an attribute is of type "select"
  isSelect: (attr) ->
    return $("##{attr} select").exists()
  
  #- sets the text input or select to display a certain value
  setAttribute: (attr, value) ->
    $("##{attr} input[type='checkbox']").attr("checked",value? and value isnt "*")
    if @isText(attr)
      if value is "*"
        $("##{attr} input[type='text']").val("").attr("placeholder","different")
      else
        $("##{attr} input[type='text']").val(value).removeAttr("placeholder")
    else if @isSelect(attr)
      $("##{attr} select").val(value).change()
    else
      $("##{attr} textarea").val(value)

  
  ## [ DOM EVENTS ] ##
  
  '.browse click': ->
    window.location.href = "/images"
  
  #- select all/select none
  '.all click': (el) ->
    if el.text().indexOf('all') != -1
      $("#imagelist li").addClass('selected')
      el.text('select none')
    else
      $("#imagelist li").removeClass('selected')
      el.text('select all')
    @showCommonImageMetaData()
    
  '.clearImages click': (el) ->
    $("#imagelist").html("")
    @imageCookie.clear()
    
  #- select individual images
  '#imagelist li click': (el) ->
    if el.hasClass('selected')
      el.removeClass('selected')
    else
      el.addClass('selected')
    @showCommonImageMetaData()
    
  #- delete individual image
  '.close click': (el) ->
    if el.parent().hasClass('delete')
      imageId = el.parent().data('id')
      el.parent().hide()
    else
      el.parent().addClass('delete')
  
  '.dontDelete click': (el) ->
    el.closest('li').removeClass('delete')

  #- "category" input (select) change
  '#type select change': (el) ->
    $("#category select option[class!='label']").remove()
    if el.val().length > 0
      categories = $("option:selected",el).data("categories")
      $("#category select").append("<option>#{category}</option>") for category in categories

  #- input (select, text) focus
  'input[type="text"],select focus': (el) ->
    $("input[type='checkbox']",el.parent()).attr("checked",true)

  #- input (select, text) blur - update Meta
  'input[type="text"],textarea,select blur': (el) ->
    value = el.val().trim()
    doUpdate = value.length > 0
    $("input[type='checkbox']",el.parent()).attr("checked",doUpdate)
    return if not doUpdate
    attribute = el.parent().attr('id')
    $('#imagelist li.selected').each (index,element) =>
      meta = $(element).data 'image'
      meta[attribute] = value
      $(element).data 'image',meta


  #- resets all data to original
  '.reset click': (el) ->
    $("#imagelist li").removeClass("selected")
    @displayMetaData {}
    $('#imagelist li').each (index,element) =>
      imageId = $(element).data 'id'
      @model.getImage imageId,{},(data) =>
        $(element).data('image',data)
      $(element).show()
      
  #- saves all data and goes back to ib_browser
  '.save click': (el) ->
    @imageCookie.clear()
    $('#imagelist li').each (index,element) =>
      imageId = $(element).data('id')
      if $(element).is(":visible")
        data = $(element).data 'image'
        delete data.date # special cases for UI display - remove before submitting
        delete data.user
        data.section = data.type
        @model.update imageId,{image: data},=>
          @imageCookie.add image.id
      else
        @model.disable imageId,{},=>
          @imageCookie.remove imageId
        
    window.location.href = "/images"  

  #- cancels all data changes and goes back to ib_browser
  '.cancel click': (el) ->
    $('#imagelist li.selected').each (index,element) =>
      imageId = $(element).data('id')
      @model.disable imageId,{},@callback('disable',$(element),imageId)
      
    window.location.href = "/images"
