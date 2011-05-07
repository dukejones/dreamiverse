$.Controller 'Dreamcatcher.Controllers.IbManager',

  model: Dreamcatcher.Models.ImageBank
  
  init: ->
    @populateLists()
    @createUploader()
    @loadImages()

  loadImages: ->
    @model.getImage image,{},@callback('showImage') for image in @getImages()
  
  ##cookies
  getImages: ->
    return $.cookie("selectedImages").split(",") if $.cookie("selectedImages")?
    return null
  
  addImage: (imageId) ->
    images = @getImages()
    if not images?
      $.cookie("selectedImages",imageId)
    else if images.indexOf(imageId) is -1
      images.push(imageId)
      $.cookie("selectedImages",images.join(","))

  removeImage: (imageId) ->
    images = @getImages()
    if not images?
      return
    newImages = images.filter (item) ->
      return item isnt imageId.toString()
    $.cookie("selectedImages",newImages.join(","))
      
  showImage: (image) ->
    $("#imagelist").append(@view('show',image))
  
   
  populateLists: ->
    $("#type select").append("<option>#{type}</option>") for type in @model.types
    for category in @model.categories
      $("#category select").append("<option>#{category.name}</option>")
      $("#category select option:last").data("genres",category.genres)
  
  
  isText: (attr) ->
    return $("##{attr} input[type='text']").exists()

  isSelect: (attr) ->
    return $("##{attr} select").exists()

  getAttribute: (attr,selectedOnly) ->
    return null if not $("##{attr} input[type='checkbox']").attr("checked") and selectedOnly

    if @isText(attr)
      return $("##{attr} input[type='text']").val()
    else if @isSelect(attr)
      return $("##{attr} select option:selected").val()
    else
      log $("##{attr} textarea").val()
      return $("##{attr} textarea").val()
  
  setAttribute: (attr, value) ->
    $("##{attr} input[type='checkbox']").attr("checked",value? and value isnt "*")
    if @isText(attr)
      if value is "*"
        $("##{attr} input[type='text']").val("").attr("placeholder","different")
      else
        $("##{attr} input[type='text']").val(value).removeAttr("placeholder")
    else if @isSelect(attr)
      $("##{attr} select").val(value)
    else
      $("##{attr} textarea").val(value)
  
  ###
  grabMetaData: () ->
    selectedOnly = true
    image = {}
    for attribute in @model.attributes
      value = @getAttribute(attribute,selectedOnly)
      image[attribute] = value if value? or not selectedOnly
    image.section = "Library"
    log image
    return {image: image}
  ###
    
  displayMetaData: (image) ->
    image.date = image.created_at if image.created_at?
    image.user = image.uploaded_by_id if image.uploaded_by_id?
    @setAttribute(attribute,image[attribute]) for attribute in @model.attributes
    
  showCommonMeta: ->
    common = {}
    $("#imagelist li.selected").each (index, element) =>
      data = $(element).data 'image'
      for attr in @model.attributes
        if not common[attr]?
          common[attr] = data[attr]
        else if common[attr] isnt data[attr]
          common[attr] = '*'
    @displayMetaData(common)
    
  createUploader: ->
    
    uploader = new qq.FileUploader {
      element: $('#uploader').get(0)
      action: '/images.json'
      maxConnections: 1
      params: {
        image: {
          type: "Bedsheet"
          category: "Classical Art"
          genre: "Africa"
        }
      }
      debug: true
      onSubmit: (id, fileName) ->
        log id+' '+fileName
      onComplete: (id, fileName, result) =>
        image_url = result.image_url
        log image_url
        image = result.image
        $("#imagelist li").each (index,element) ->
          $(element).remove() if $(".upload-file",element).text() is fileName
        @showImage image
        @addImage image.id
      template: $("#uploader").html()
      fileTemplate: @view('fileTemplate')
      classes: {
        button: 'browse'
        drop: 'dropArea'
        dropActive: 'active'
        list: 'imagelist'
        progress: 'progress-meter'
        file: 'upload-file'
        spinner: 'spinner'
        size: 'upload-size'
        cancel: 'close'
        success: 'upload-success'
        fail: 'upload-fail'
      }
    }
  
  '#imagelist li click': (el) ->
    if el.hasClass('selected')
      el.removeClass('selected')
    else
      el.addClass('selected')
      @displayMetaData el.data('image')
    
    @showCommonMeta()
    
  '.all click': (el) ->
    if el.text().indexOf('all') != -1
      $("#imagelist li").addClass('selected')
      el.text('select none')
    else
      $("#imagelist li").removeClass('selected')
      el.text('select all')
      
    @showCommonMeta()
  
  '.save click': (el) ->
    $('#imagelist li').each (index,element) =>
      imageId = $(element).data('id')
      if $(element).is(":visible")
        imageMeta = $(element).data('image')
        @model.update imageId,{image: imageMeta}
      else
        @model.disable imageId,{},=>
          @removeImage imageId

  'input[type="text"],select focus': (el) ->
    $("input[type='checkbox']",el.parent()).attr("checked",true)
    
  'input[type="text"],select blur': (el) ->
    $("input[type='checkbox']",el.parent()).attr("checked",el.val().length > 0)
    value = el.val()
    attribute = el.parent().attr('id')
    $('#imagelist li.selected').each (index,element) =>
      meta = $(element).data 'image'
      meta[attribute] = value
      $(element).data 'image',meta
        
      
  '.cancel click': (el) ->
    $('#imagelist li.selected').each (index,element) =>
      imageId = $(element).data('id')
      @model.disable imageId,{},@callback('disable',$(element),imageId)
      
  '#category select change': (el) ->
    genres = $("option:selected",el).data("genres")
    $("#genre select").html("")
    $("#genre select").append("<option>#{genre}</option>") for genre in genres
    
  '.close click': (el) ->
    if el.parent().css('opacity') is '0.5'
      imageId = el.parent().data('id')
      el.parent().hide()
    else
      el.parent().css('opacity',0.5)
      
  '.reset click': (el) ->
    $("#imagelist li").removeClass("selected")
    @displayMetaData {}
    $('#imagelist li').each (index,element) =>
      imageId = $(element).data 'id'
      @model.getImage imageId,{},(data) =>
        $(element).data('image',data)
      $(element).show()
      
        
  
  
